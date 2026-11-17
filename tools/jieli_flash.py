"""Bounded AC632N JLFS decoding, app replacement and space allocation.

Format reference: kagaimiq/jl-misctools (ENC, SFC, JLFS and chip-key
layout). This implementation preserves addresses, reservations and opaque
bytes. It does not establish that modified code can run on a device.
"""
import struct
from dataclasses import dataclass

from tools.inspect_bup import crc16, enc, require, sha256


def sfc(data, key, offset=0):
    """XOR 32-byte blocks; offset is relative to the cipher's origin."""
    require(offset >= 0 and offset % 32 == 0, 'SFC offset must be block aligned')
    return b''.join(enc(data[i:i + 32], (key ^ ((offset + i) >> 2)) & 0xffff)
                    for i in range(0, len(data), 32))


def chip_key(blob):
    require(len(blob) >= 34, 'Truncated chip-key record')
    require(crc16(blob[:32]) == int.from_bytes(blob[32:34], 'little'),
            'Chip-key CRC failed')
    threshold = sum(blob[:16]) & 255
    if threshold >= 0xe0:
        threshold = 0xaa
    elif threshold <= 0x10:
        threshold = 0x55
    return sum(1 << bit for bit in range(16)
               if blob[16 + bit] ^ blob[15 - bit] < threshold)


@dataclass(frozen=True)
class Entry:
    header_offset: int
    data_crc: int
    offset: int
    size: int
    flags: int
    last: int
    name: str

    @property
    def reserved(self):
        return bool(self.flags & 0x10)


def entry_at(data, offset):
    require(0 <= offset <= len(data) - 32, 'JLFS header outside image')
    raw = data[offset:offset + 32]
    hcrc, dcrc, off, size, flags, _, last, name = struct.unpack('<HHIIBBH16s', raw)
    require(crc16(raw[2:]) == hcrc, f'JLFS header CRC failed at {offset:#x}')
    name = name.split(b'\0')[0].decode('ascii')
    require(name and '/' not in name and '\\' not in name and name not in ('.', '..'),
            'Invalid JLFS entry name')
    return Entry(offset, dcrc, off, size, flags, last, name)


def checked_payload(data, offset, size, checksum, label):
    require(offset >= 0 and size >= 0 and offset + size <= len(data),
            f'{label}: payload outside image')
    result = data[offset:offset + size]
    require(crc16(result) == checksum, f'{label}: data CRC failed')
    return result


def decode_spl(raw):
    """Decode bank headers/bodies and validate before returning the SPL."""
    require(len(raw) >= 16, 'Truncated SPL')
    decoded = bytearray(raw)
    first = enc(raw[:16])
    count = int.from_bytes(first[:2], 'little')
    require(1 <= count <= len(raw) // 16, 'Invalid SPL bank count')
    ranges = [(0, count * 16)]
    for i in range(count):
        start = i * 16
        header = enc(raw[start:start + 16])
        _, size, _, off, dcrc, hcrc = struct.unpack('<HHIIHH', header)
        require(crc16(header[:14]) == hcrc, 'SPL bank header CRC failed')
        require(off >= count * 16 and off + size <= len(raw), 'SPL bank outside image')
        require(all(off >= end or off + size <= begin for begin, end in ranges),
                'Overlapping SPL banks')
        ranges.append((off, off + size))
        body = enc(raw[off:off + size])
        require(crc16(body) == dcrc, 'SPL bank data CRC failed')
        decoded[start:start + 16] = header
        decoded[off:off + size] = body
    return bytes(decoded)


class FlashImage:
    def __init__(self, raw):
        self.raw = bytes(raw)
        require(len(raw) >= 64, 'Truncated Flash image')
        header = enc(raw[:32])
        require(crc16(header[2:]) == int.from_bytes(header[:2], 'little'),
                'Flash header CRC failed')
        self.top = []
        decoded_top = bytearray(raw)
        for off in range(32, len(raw) - 31, 32):
            decoded_top[off:off + 32] = enc(raw[off:off + 32])
            ent = entry_at(decoded_top, off)
            require(ent.name not in {e.name for e in self.top}, 'Duplicate top entry')
            self.top.append(ent)
            if ent.last:
                break
        require(self.top and self.top[-1].last, 'Unterminated top directory')
        top_end = self.top[-1].header_offset + 32
        dirs = [e for e in self.top if e.name == 'app_dir_head' and e.flags == 0x81]
        configs = [e for e in self.top if e.name == 'isd_config.ini']
        require(len(dirs) == len(configs) == 1, 'Missing app directory or chip config')
        self.base = dirs[0].offset
        require(top_end <= self.base < len(raw) and self.base % 32 == 0,
                'Invalid app directory base')
        config = configs[0]
        require(top_end <= config.offset and config.offset + config.size <= self.base,
                'Chip config overlaps directory or app')
        config_data = checked_payload(raw, config.offset, config.size,
                                      config.data_crc, 'Flash chip config')
        self.key = chip_key(config_data)
        for ent in self.top:
            if ent is config or ent.flags == 0x81 or ent.reserved:
                continue
            require(ent.offset >= top_end and ent.offset + ent.size <= self.base,
                    'Top file overlaps directory or app')
            payload = raw[ent.offset:ent.offset + ent.size]
            if ent is self.top[0]:
                payload = decode_spl(payload)
            require(crc16(payload) == ent.data_crc, f'{ent.name}: top data CRC failed')

        self.plain = bytearray(raw)
        self.plain[self.base:] = sfc(raw[self.base:], self.key)
        self.blocks = []
        self.children = []
        off = self.base
        while off <= len(raw) - 32:
            ent = entry_at(self.plain, off)
            require(ent.size >= 32 and off + ent.size <= len(raw),
                    'App/resource block outside image')
            require(not ent.reserved and ent.flags in (0x82, 0x83),
                    'Unsupported app/resource block')
            checked_payload(self.plain, off + 32, ent.size - 32,
                            ent.data_crc, ent.name)
            self.blocks.append(ent)
            if ent.last:
                break
            off += ent.size
        require(self.blocks and self.blocks[-1].last, 'Unterminated resource list')
        parent = self.blocks[0]
        require(parent.name == 'app_area_head' and parent.flags == 0x83,
                'Unexpected app parent')
        self.entry_point = parent.offset
        for off in range(self.base + 32, self.base + parent.size - 31, 32):
            ent = entry_at(self.plain, off)
            require(ent.name not in {e.name for e in self.children}, 'Duplicate child entry')
            self.children.append(ent)
            if ent.last:
                break
        require(self.children and self.children[-1].last, 'Unterminated app directory')
        child_headers_end = self.children[-1].header_offset + 32
        occupied = []
        for ent in self.children:
            if ent.reserved:
                continue  # Physical Flash reservations are not packaged file payloads.
            require(ent.flags == 0x82, 'Unsupported child flags')
            start, end = self.base + ent.offset, self.base + ent.offset + ent.size
            require(child_headers_end <= start and end <= self.base + parent.size,
                    'Child file outside app parent')
            require(all(start >= b or end <= a for a, b in occupied), 'Overlapping child files')
            occupied.append((start, end))
            checked_payload(self.plain, start, ent.size, ent.data_crc, ent.name)
        require(any(e.name == 'app.bin' and not e.reserved for e in self.children),
                'Missing app.bin')
        # Child reservations use the app-directory origin (as JLFS offsets).
        # This is a static packaging bound, not a runtime Flash driver contract.
        self.reserved_start = min((self.base + e.offset for e in self.children if e.reserved),
                                  default=len(raw))
        require(len(raw) <= self.reserved_start, 'Packaged Flash overlaps reserved storage')

    def file(self, name):
        ent = next(e for e in self.children if e.name == name and not e.reserved)
        return bytes(self.plain[self.base + ent.offset:self.base + ent.offset + ent.size])

    def rebuild(self, application=None):
        """Keep file sizes/addresses fixed; update leaf then parent CRCs."""
        plain = bytearray(self.plain)
        if application is not None:
            app = next(e for e in self.children if e.name == 'app.bin')
            require(len(application) == app.size, 'Application replacement must keep its size')
            start = self.base + app.offset
            plain[start:start + app.size] = application
            self._update_crc(plain, app.header_offset, crc16(application))
            parent = self.blocks[0]
            self._update_crc(plain, parent.header_offset,
                             crc16(plain[self.base + 32:self.base + parent.size]))
        result = bytearray(self.raw)
        result[self.base:] = sfc(plain[self.base:], self.key)
        # This checks the newly computed CRC chain, not just XOR invertibility.
        verify = FlashImage(result)
        require(verify.file('app.bin') == (self.file('app.bin') if application is None
                                         else application), 'Replacement verification failed')
        return bytes(result)

    def grow_application(self, application):
        """Append a 32-byte-multiple extension, relocating following file data.

        Existing application addresses and all physical reservation descriptors
        remain fixed. No runtime relocation or bootability is implied.
        """
        app = next(e for e in self.children if e.name == 'app.bin')
        delta = len(application) - app.size
        require(delta > 0 and delta % 32 == 0, 'Application growth must be a positive multiple of 32')
        require(len(self.raw) + delta <= self.reserved_start,
                'Application growth would enter reserved Flash storage')
        start = self.base + app.offset
        end = start + app.size
        plain = self.plain[:start] + application + self.plain[end:]
        parent = self.blocks[0]
        for child in self.children:
            if child.reserved:
                continue
            if child is app:
                struct.pack_into('<I', plain, child.header_offset + 8, len(application))
                self._update_crc(plain, child.header_offset, crc16(application))
            elif self.base + child.offset >= end:
                struct.pack_into('<I', plain, child.header_offset + 4, child.offset + delta)
                self._update_crc(plain, child.header_offset, child.data_crc)
        struct.pack_into('<I', plain, self.base + 8, parent.size + delta)
        self._update_crc(plain, self.base, crc16(plain[self.base + 32:self.base + parent.size + delta]))
        result = self.raw[:self.base] + sfc(plain[self.base:], self.key)
        verify = FlashImage(result)
        require(verify.file('app.bin') == application, 'Grown app failed verification')
        return result

    @staticmethod
    def _update_crc(data, offset, checksum):
        struct.pack_into('<H', data, offset + 2, checksum)
        struct.pack_into('<H', data, offset, crc16(data[offset + 2:offset + 32]))

    def report(self):
        return {'sha256': sha256(self.raw), 'size': len(self.raw),
                'app_base': hex(self.base), 'entry_point': hex(self.entry_point),
                'chip_key': hex(self.key), 'app_sha256': sha256(self.file('app.bin')),
                'top_header_count': len(self.top), 'app_resource_header_count': len(self.blocks),
                'child_header_count': len(self.children),
                'physical_reserved_start': self.reserved_start,
                'packaged_growth_available': self.reserved_start - len(self.raw),
                'reservations': [{'name': e.name, 'offset': e.offset, 'size': e.size,
                                  'flags': e.flags} for e in self.children if e.reserved],
                'opaque_trailing_bytes': len(self.raw) -
                (self.blocks[-1].header_offset + self.blocks[-1].size)}
