import struct
import tempfile
import unittest
import zlib
from pathlib import Path

from tools.inspect_bup import crc16, enc, inspect_bup, inspect_ufw


def ufw_fixture(payload=b'flash-payload'):
    entry = enc(struct.pack('<HHHHIII44s16s', 0, 0, crc16(payload), 0,
                            144, len(payload), len(payload), b'', b'flash.bin'))
    header = bytearray(struct.pack('<HHIHHI48s', 0, crc16(entry), 144 + len(payload),
                                   1, 4, 512, b'AC632N'))
    struct.pack_into('<H', header, 0, crc16(header[2:]))
    return enc(header) + entry + payload


def bup_fixture():
    header = bytearray(139)
    magic = b'BigBigWon Upgrade Pack\0'
    header[:len(magic)] = magic
    for off, name in ((43, b'variant-a.ufw'), (91, b'variant-b.ufw')):
        header[off:off + len(name)] = name
    out = bytearray(header)
    for payload in (b'first-flash', b'second-flash'):
        image = ufw_fixture(payload)
        packed = bytearray()
        for off in range(0, len(image), 64):
            raw = image[off:off + 64]
            compressed = zlib.compress(raw, 6)
            packed.extend(struct.pack('<II', len(compressed), len(raw)))
            packed.extend(compressed)
        out.extend(struct.pack('<I', len(packed)))
        out.extend(packed)
    return bytes(out)


class ContainerTests(unittest.TestCase):
    def test_two_images_and_exact_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)
            report = inspect_bup(bup_fixture(), path)
            self.assertTrue(report['zlib_level6_roundtrip_byte_identical'])
            self.assertEqual(len(report['images']), 2)
            self.assertEqual((path / 'controller-0-entries/flash.bin').read_bytes(), b'first-flash')
            self.assertEqual((path / 'controller-1-entries/flash.bin').read_bytes(), b'second-flash')

    def test_corrupt_ufw_header(self):
        data = bytearray(ufw_fixture())
        data[20] ^= 1
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, 'header CRC'):
                inspect_ufw(data, Path(tmp))

    def test_corrupt_flash_payload(self):
        data = bytearray(ufw_fixture())
        data[-1] ^= 1
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, 'payload CRC'):
                inspect_ufw(data, Path(tmp))

    def test_truncated_and_trailing_bup(self):
        for data in (bup_fixture()[:-1], bup_fixture() + b'extra'):
            with self.subTest(size=len(data)), tempfile.TemporaryDirectory() as tmp:
                with self.assertRaises(ValueError):
                    inspect_bup(data, Path(tmp))

    def test_incorrect_block_raw_size(self):
        data = bytearray(bup_fixture())
        struct.pack_into('<I', data, 147, 63)
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, 'block size'):
                inspect_bup(data, Path(tmp))


if __name__ == '__main__':
    unittest.main()
