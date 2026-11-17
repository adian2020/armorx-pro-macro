import struct
import unittest
import zlib

from tools.firmware_container import BupPackage, UfwImage
from tools.inspect_bup import crc16, enc
from tools.jieli_flash import FlashImage, sfc


def jlfs(name, off, size, flags, checksum=0xffff, last=0):
    h = bytearray(struct.pack('<HHIIBBH16s', 0, checksum, off, size, flags, 255, last,
                              name.encode() + b'\0'))
    struct.pack_into('<H', h, 0, crc16(h[2:]))
    return bytes(h)


def flash_fixture(key=0x5555, vm=0x1000):
    # A zero chip-key blob decodes to all 1 bits, the 0xff half to all 0 bits.
    blob = bytes(16) + bytes(0 if key & (1 << i) else 255 for i in range(16))
    config = blob + struct.pack('<H', crc16(blob))
    bank_body = b'SPL!'
    bank = bytearray(struct.pack('<HHIIHH', 1, len(bank_body), 0x2000, 16,
                                 crc16(bank_body), 0))
    struct.pack_into('<H', bank, 14, crc16(bank[:14]))
    spl_plain = bank + bank_body
    spl_stored = enc(bank) + enc(bank_body)
    app = bytes(range(96))
    cfg = b'calibration'
    parent_size = 160 + len(app) + len(cfg)
    children = (jlfs('app.bin', 160, len(app), 0x82, crc16(app)) +
                jlfs('cfg_tool.bin', 256, len(cfg), 0x82, crc16(cfg)) +
                jlfs('VM', vm, 0x10000, 0x12) +
                jlfs('USERIF', 0x7d000, 8192, 0x92, last=1))
    area_body = children + app + cfg
    area = jlfs('app_area_head', 0x1e00120, parent_size, 0x83, crc16(area_body)) + area_body
    resource_body = b'secondary-cpu'
    resource = jlfs('p11_code.bin', 32, 32 + len(resource_body), 0x82,
                    crc16(resource_body), last=1) + resource_body
    # The resource header crosses an SFC block boundary by design.
    header = bytearray(32)
    struct.pack_into('<H', header, 0, crc16(header[2:]))
    top = (jlfs('uboot.boot', 160, len(spl_stored), 0x40, crc16(spl_plain)) +
           jlfs('isd_config.ini', 180, len(config), 2, crc16(config)) +
           jlfs('app_dir_head', 256, 0xffffffff, 0x81) +
           jlfs('key_mac', 0x7f000, 4096, 0x12, last=1))
    stored = enc(header) + b''.join(enc(top[i:i + 32]) for i in range(0, len(top), 32))
    return stored + spl_stored + config + bytes(42) + sfc(area + resource + b'opaque-tail', key)


def ufw_fixture(key=0x5555):
    files = [(0, 'flash.bin', flash_fixture(key)), (2, 'info.log', b''),
             (52, 'isd_config.ini', b'[config]\n'), (100, 'ota.bin', b'OTA-original'),
             (251, 'script.ver', b'AC632N-test'),
             (32, 'flash2.bin', flash_fixture(key, 0x1100)),
             (33, 'flash3.bin', flash_fixture(key, 0x1200)),
             (34, 'flash4.bin', flash_fixture(key, 0x1300)),
             (251, 'farg.cfg', b'ARG!'), (161, 'blimit.bin', b'limit' * 19),
             (255, 'tail.bin', b'unknown-version-fields' + b'JLUFW' + bytes(11))]
    out = bytearray(1024)
    rows = bytearray()
    for typ, name, plain in files:
        off = len(out)
        stored = sfc(plain, key, off) if typ in (52, 161, 251) else plain
        allocation = (len(stored) + 31) // 32 * 32
        rows.extend(enc(struct.pack('<HHHHIII44s16s', typ, 0, crc16(plain), 0, off,
                                    len(stored), allocation, b'', name.encode())))
        out.extend(stored + bytes(allocation - len(stored)))
    header = bytearray(struct.pack('<HHIHHI48s', 0, crc16(rows), len(out), len(files),
                                   4, 512, b'AC632N'))
    struct.pack_into('<H', header, 0, crc16(header[2:]))
    out[:64] = enc(header)
    out[64:64 + len(rows)] = rows
    return bytes(out)


def bup_fixture():
    out = bytearray(139)
    magic = b'BigBigWon Upgrade Pack\0'
    out[:len(magic)] = magic
    for key in (0x5555, 0xa5a5):
        raw = ufw_fixture(key)
        blocks = bytearray()
        for off in range(0, len(raw), 128):
            part = raw[off:off + 128]
            packed = zlib.compress(part, 6)
            blocks.extend(struct.pack('<II', len(packed), len(part)) + packed)
        out.extend(struct.pack('<I', len(blocks)) + blocks)
    return bytes(out)


class NestedContainerTests(unittest.TestCase):
    def test_flash_fixed_size_change_and_inverse_are_exact(self):
        original = flash_fixture()
        image = FlashImage(original)
        self.assertEqual(image.rebuild(), original)
        app = bytearray(image.file('app.bin'))
        app[-1] ^= 1
        updated = FlashImage(image.rebuild(app))
        self.assertEqual(updated.file('app.bin'), app)
        self.assertEqual(updated.file('cfg_tool.bin'), image.file('cfg_tool.bin'))
        self.assertEqual(updated.report()['reservations'], image.report()['reservations'])
        self.assertEqual(updated.rebuild(image.file('app.bin')), original)

    def test_refuse_application_growth_and_shrink(self):
        image = FlashImage(flash_fixture())
        for size in (95, 97):
            with self.assertRaisesRegex(ValueError, 'keep its size'):
                image.rebuild(bytes(size))

    def test_growth_moves_files_and_auxiliaries_preserving_content(self):
        original = BupPackage(bup_fixture())
        old_app = original.images[0].flashes['flash.bin'].file('app.bin')
        expanded = old_app + b'additional-code-space'.ljust(64, b'\0')
        result = BupPackage(original.rebuild(expanded, grow=True))
        for old, new in zip(original.images, result.images):
            self.assertEqual(old.auxiliary, new.auxiliary)
            for name, flash in new.flashes.items():
                previous = old.flashes[name]
                self.assertEqual(flash.file('app.bin'), expanded)
                self.assertEqual(flash.file('cfg_tool.bin'), previous.file('cfg_tool.bin'))
                self.assertEqual(flash.report()['reservations'], previous.report()['reservations'])
                self.assertEqual(flash.report()['entry_point'], previous.report()['entry_point'])
                for a, b in zip(previous.blocks[1:], flash.blocks[1:]):
                    self.assertEqual(a.name, b.name)
                    self.assertEqual(previous.plain[a.header_offset:a.header_offset + a.size],
                                     flash.plain[b.header_offset:b.header_offset + b.size])
            old_tail = next(e for e in old.entries if e.name == 'tail.bin')
            new_tail = next(e for e in new.entries if e.name == 'tail.bin')
            self.assertEqual(old.payload(old_tail), new.payload(new_tail))
            self.assertGreater(new_tail.offset, old_tail.offset)
        self.assertEqual(result.rebuild(), original.rebuild(expanded, grow=True))

    def test_growth_rejects_reserved_storage_collision_and_misalignment(self):
        image = FlashImage(flash_fixture(vm=400))
        app = image.file('app.bin')
        for delta in (1, 31):
            with self.assertRaisesRegex(ValueError, 'multiple of 32'):
                image.grow_application(app + bytes(delta))
        with self.assertRaisesRegex(ValueError, 'reserved Flash'):
            image.grow_application(app + bytes(256))

    def test_complete_bup_replacement_and_inverse_all_eight_variants(self):
        raw = bup_fixture()
        package = BupPackage(raw)
        self.assertEqual(package.rebuild(), raw)
        old_app = package.images[0].flashes['flash.bin'].file('app.bin')
        app = bytearray(old_app)
        app[47] ^= 1
        changed = BupPackage(package.rebuild(app))
        for old, new in zip(package.images, changed.images):
            for flash in new.flashes.values():
                self.assertEqual(flash.file('app.bin'), app)
            for ent in old.entries:
                if ent.name not in old.flashes:
                    other = next(e for e in new.entries if e.name == ent.name)
                    self.assertEqual(old.payload(ent), new.payload(other))
        self.assertEqual(changed.rebuild(old_app), raw)

    def test_auxiliary_origin_and_block_restart(self):
        image = UfwImage(ufw_fixture())
        ent = next(e for e in image.entries if e.name == 'blimit.bin')
        self.assertEqual(image.auxiliary[ent.name], b'limit' * 19)
        self.assertNotEqual(sfc(image.payload(ent), image.key), image.auxiliary[ent.name])
        for origin in (0, 32, 1024):
            value = bytes(range(91))
            self.assertEqual(sfc(sfc(value, image.key, origin), image.key, origin), value)
        with self.assertRaisesRegex(ValueError, 'block aligned'):
            sfc(b'bad', image.key, 1)

    def test_nested_corruption_rejected(self):
        original = flash_fixture()
        image = FlashImage(original)
        for pos, label in ((0, 'Flash header'), (34, 'JLFS header'),
                           (162, 'SPL bank header'), (177, 'SPL bank data'),
                           (181, 'Flash chip config'), (256 + 48, 'data CRC'),
                           (256 + 161, 'data CRC')):
            changed = bytearray(original)
            changed[pos] ^= 1
            with self.subTest(layer=label), self.assertRaisesRegex(ValueError, label):
                FlashImage(changed)
        # Repair parent CRC to ensure a broken child CRC is still rejected.
        plain = bytearray(image.plain)
        plain[256 + 160] ^= 1
        parent = image.blocks[0]
        FlashImage._update_crc(plain, 256, crc16(plain[288:256 + parent.size]))
        changed = original[:256] + sfc(plain[256:], image.key)
        with self.assertRaisesRegex(ValueError, 'app.bin: data CRC'):
            FlashImage(changed)

    def test_outer_auxiliary_corruption_rejected(self):
        original = ufw_fixture()
        image = UfwImage(original)
        for ent in image.entries:
            if ent.name in image.auxiliary:
                changed = bytearray(original)
                changed[ent.offset + ent.size - 1] ^= 1
                with self.subTest(name=ent.name), self.assertRaisesRegex(ValueError, 'payload CRC'):
                    UfwImage(changed)

    def test_reserved_ranges_are_not_treated_as_payload(self):
        image = FlashImage(flash_fixture())
        self.assertGreater(image.report()['reservations'][0]['size'], len(image.raw))
        self.assertEqual(image.rebuild(), image.raw)

    def test_truncation_and_trailing_data(self):
        raw = bup_fixture()
        for cut in (0, 138, 145, len(raw) - 1):
            with self.subTest(cut=cut), self.assertRaises(ValueError):
                BupPackage(raw[:cut])
        with self.assertRaisesRegex(ValueError, 'trailing'):
            BupPackage(raw + b'x')

    def test_ufw_payload_overlap_with_repaired_header_and_list_crc(self):
        raw = bytearray(ufw_fixture())
        image = UfwImage(raw)
        target = image.entries[2]
        row = bytearray(enc(raw[target.table_offset:target.table_offset + 80]))
        struct.pack_into('<I', row, 8, image.entries[0].offset)
        raw[target.table_offset:target.table_offset + 80] = enc(row)
        header = bytearray(enc(raw[:64]))
        struct.pack_into('<H', header, 2, crc16(raw[64:64 + 80 * len(image.entries)]))
        struct.pack_into('<H', header, 0, crc16(header[2:]))
        raw[:64] = enc(header)
        with self.assertRaisesRegex(ValueError, 'Overlapping UFW'):
            UfwImage(raw)


if __name__ == '__main__':
    unittest.main()
