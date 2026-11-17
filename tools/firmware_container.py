"""V41 BUP/UFW roundtrip and in-memory, fixed-layout replacement backend."""
import struct
import zlib
from dataclasses import dataclass

from tools.inspect_bup import crc16, enc, require, sha256
from tools.jieli_flash import FlashImage, sfc

FLASH_TYPES = {0: 'flash.bin', 32: 'flash2.bin', 33: 'flash3.bin', 34: 'flash4.bin'}
AUX_TYPES = {52, 161, 251}


@dataclass(frozen=True)
class UfwEntry:
    table_offset: int
    type: int
    offset: int
    size: int
    allocation: int
    checksum: int
    name: str


class UfwImage:
    def __init__(self, raw):
        self.raw = bytes(raw)
        require(len(raw) >= 64, 'Truncated UFW header')
        self.header = enc(raw[:64])
        hcrc, lcrc, size, count, _, _, chip = struct.unpack('<HHIHHI48s', self.header)
        require(crc16(self.header[2:]) == hcrc, 'UFW header CRC failed')
        require(size == len(raw), 'UFW length mismatch')
        require(chip.split(b'\0')[0] == b'AC632N', 'Unsupported UFW chip')
        require(1 <= count <= (len(raw) - 64) // 80, 'Invalid UFW entry count')
        list_end = 64 + 80 * count
        require(crc16(raw[64:list_end]) == lcrc, 'UFW entry-list CRC failed')
        self.entries = []
        occupied = []
        for table_off in range(64, list_end, 80):
            row = enc(raw[table_off:table_off + 80])
            typ, _, checksum, _, off, size, alloc, _, name = struct.unpack('<HHHHIII44s16s', row)
            name = name.split(b'\0')[0].decode('ascii')
            require(name and '/' not in name and '\\' not in name and name not in ('.', '..'),
                    'Invalid UFW name')
            require(name not in {e.name for e in self.entries}, 'Duplicate UFW name')
            require(size <= alloc and off >= list_end and off + alloc <= len(raw),
                    'UFW allocation outside image')
            if alloc:
                require(all(off >= b or off + alloc <= a for a, b in occupied),
                        'Overlapping UFW allocations')
                occupied.append((off, off + alloc))
            self.entries.append(UfwEntry(table_off, typ, off, size, alloc, checksum, name))
        self.flashes = {}
        for typ, name in FLASH_TYPES.items():
            matches = [e for e in self.entries if e.type == typ and e.name == name]
            require(len(matches) == 1, 'Missing Flash variant ' + name)
            ent = matches[0]
            payload = self.payload(ent)
            require(crc16(payload) == ent.checksum, name + ': UFW payload CRC failed')
            self.flashes[name] = FlashImage(payload)
        keys = {f.key for f in self.flashes.values()}
        require(len(keys) == 1, 'Flash variants disagree on chip key')
        self.key = keys.pop()
        require(len({f.file('app.bin') for f in self.flashes.values()}) == 1,
                'Flash variants contain different applications')
        self.auxiliary = {}
        for ent in self.entries:
            if ent.name in self.flashes:
                continue
            payload = self.payload(ent)
            if ent.type in AUX_TYPES:
                require(ent.offset % 32 == 0, 'Unaligned auxiliary SFC origin')
                payload = sfc(payload, self.key, ent.offset)
                self.auxiliary[ent.name] = payload
            else:
                require(ent.type in (2, 100, 255), 'Unsupported UFW entry type')
            require(crc16(payload) == ent.checksum, ent.name + ': UFW payload CRC failed')

    def payload(self, ent):
        return self.raw[ent.offset:ent.offset + ent.size]

    def rebuild(self, application=None):
        out = bytearray(self.raw)
        for ent in self.entries:
            if ent.name not in self.flashes:
                continue
            payload = self.flashes[ent.name].rebuild(application)
            out[ent.offset:ent.offset + ent.size] = payload
            row = bytearray(enc(self.raw[ent.table_offset:ent.table_offset + 80]))
            struct.pack_into('<H', row, 4, crc16(payload))
            out[ent.table_offset:ent.table_offset + 80] = enc(row)
        header = bytearray(self.header)
        list_end = 64 + 80 * len(self.entries)
        struct.pack_into('<H', header, 2, crc16(out[64:list_end]))
        struct.pack_into('<H', header, 0, crc16(header[2:]))
        out[:64] = enc(header)
        return bytes(out)

    def grow_application(self, application):
        """Reallocate the four Flash members; re-encrypt displaced auxiliaries.

        Unknown trailer fields are preserved. Their interpretation and device
        acceptance are not established by reparsing this container.
        """
        replacements = {name: f.grow_application(application) for name, f in self.flashes.items()}
        allocated = sorted((e for e in self.entries if e.allocation), key=lambda e: e.offset)
        first = allocated[0].offset
        out = bytearray(self.raw[:first])
        positions = {first: first}
        updates = {}
        consumed = first
        for ent in allocated:
            out.extend(self.raw[consumed:ent.offset])
            new_offset = len(out)
            positions[ent.offset] = new_offset
            if ent.name in replacements:
                payload = replacements[ent.name]
                padding = self.raw[ent.offset + ent.size:ent.offset + ent.allocation]
                allocation = (len(payload) + len(padding) + 31) // 32 * 32
                payload += padding + bytes(allocation - len(payload) - len(padding))
                size = len(replacements[ent.name])
                checksum = crc16(payload[:size])
            else:
                payload = self.raw[ent.offset:ent.offset + ent.allocation]
                if ent.type in AUX_TYPES:
                    payload = sfc(sfc(payload, self.key, ent.offset), self.key, new_offset)
                size, allocation, checksum = ent.size, ent.allocation, ent.checksum
            out.extend(payload)
            updates[ent.name] = (new_offset, size, allocation, checksum)
            consumed = ent.offset + ent.allocation
            positions[consumed] = len(out)
        out.extend(self.raw[consumed:])
        for ent in self.entries:
            if ent.allocation:
                off, size, alloc, checksum = updates[ent.name]
            else:
                require(ent.offset in positions, 'Unresolved empty-entry relocation')
                off, size, alloc, checksum = positions[ent.offset], 0, 0, ent.checksum
            row = bytearray(enc(self.raw[ent.table_offset:ent.table_offset + 80]))
            struct.pack_into('<H', row, 4, checksum)
            struct.pack_into('<III', row, 8, off, size, alloc)
            out[ent.table_offset:ent.table_offset + 80] = enc(row)
        header = bytearray(self.header)
        struct.pack_into('<I', header, 4, len(out))
        struct.pack_into('<H', header, 2, crc16(out[64:64 + 80 * len(self.entries)]))
        struct.pack_into('<H', header, 0, crc16(header[2:]))
        out[:64] = enc(header)
        verify = UfwImage(out)
        require(all(f.file('app.bin') == application for f in verify.flashes.values()),
                'Grown UFW application mismatch')
        return bytes(out)

    def report(self):
        return {'sha256': sha256(self.raw), 'size': len(self.raw),
                'all_entry_payload_crcs_valid': True,
                'auxiliary_sfc_origin': 'UFW container offset, not payload-relative',
                'auxiliary': [{'name': name, 'decoded_sha256': sha256(data)}
                              for name, data in self.auxiliary.items()],
                'tail_semantics_verified_for_modification': False,
                'flashes': {name: flash.report() for name, flash in self.flashes.items()}}


class BupPackage:
    def __init__(self, raw):
        self.raw = bytes(raw)
        require(len(raw) >= 139 and raw.startswith(b'BigBigWon Upgrade Pack\0'),
                'Unexpected BUP header')
        self.images, self.block_sizes = [], []
        pos = 139
        for _ in range(2):
            require(pos + 4 <= len(raw), 'Missing BUP image length')
            length, = struct.unpack_from('<I', raw, pos)
            pos += 4
            end = pos + length
            require(end <= len(raw), 'BUP image outside package')
            sizes, blocks = [], []
            while pos < end:
                require(pos + 8 <= end, 'Truncated BUP block header')
                packed, size = struct.unpack_from('<II', raw, pos)
                pos += 8
                require(packed > 0 and 0 < size <= 32768 and pos + packed <= end,
                        'Invalid BUP block sizes')
                decoder = zlib.decompressobj()
                block = decoder.decompress(raw[pos:pos + packed], size + 1)
                require(decoder.eof and not decoder.unused_data and not decoder.unconsumed_tail,
                        'Invalid BUP compressed block')
                require(len(block) == size, 'BUP block length mismatch')
                pos += packed
                sizes.append(size)
                blocks.append(block)
            self.images.append(UfwImage(b''.join(blocks)))
            self.block_sizes.append(sizes)
        require(pos == len(raw), 'Unexpected BUP trailing data')

    def rebuild(self, application=None, grow=False):
        out = bytearray(self.raw[:139])
        for image, sizes in zip(self.images, self.block_sizes):
            binary = image.grow_application(application) if grow else image.rebuild(application)
            blocks = bytearray()
            chunk_size = sizes[0]
            require(all(s == chunk_size for s in sizes[:-1]) and sizes[-1] <= chunk_size,
                    'Unsupported nonuniform BUP block sizes')
            for pos in range(0, len(binary), chunk_size):
                chunk = binary[pos:pos + chunk_size]
                packed = zlib.compress(chunk, 6)
                blocks.extend(struct.pack('<II', len(packed), len(chunk)))
                blocks.extend(packed)
            out.extend(struct.pack('<I', len(blocks)))
            out.extend(blocks)
        return bytes(out)
