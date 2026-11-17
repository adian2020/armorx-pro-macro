#!/usr/bin/env python3
"""Offline ARMOR-X Pro V41 BUP inspection. Does not modify firmware or contact devices."""
import argparse
import hashlib
import json
import struct
import zlib
from pathlib import Path


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def crc16(data):
    crc = 0
    for byte in data:
        crc ^= byte << 8
        for _ in range(8):
            crc = ((crc << 1) ^ (0x1021 if crc & 0x8000 else 0)) & 0xffff
    return crc


def enc(data, key=0xffff):
    out = bytearray(data)
    for i in range(len(out)):
        out[i] ^= key & 255
        key = ((key << 1) ^ (0x1021 if key & 0x8000 else 0)) & 0xffff
    return bytes(out)


def inspect_ufw(data, dest):
    dest.mkdir(parents=True, exist_ok=True)
    header = enc(data[:64])
    hcrc, listcrc, size, count, _, _, chip = struct.unpack('<HHIHHI48s', header)
    require(crc16(header[2:]) == hcrc, 'UFW header CRC failed')
    require(size == len(data), 'UFW size differs from file size')
    require(crc16(data[64:64 + count * 80]) == listcrc, 'UFW entry-list CRC failed')
    result = {'chip': chip.split(b'\0')[0].decode('ascii'), 'header_crc_valid': True,
              'entry_list_crc_valid': True, 'size': size, 'sha256': sha256(data), 'entries': []}
    for i in range(count):
        row = enc(data[64 + i * 80:144 + i * 80])
        typ, idx, checksum, flags, off, length, padded, _, name = struct.unpack('<HHHHIII44s16s', row)
        name = name.split(b'\0')[0].decode('ascii')
        require(Path(name).name == name and name not in ('', '.', '..'), 'Unsafe UFW entry name')
        require(off + length <= len(data), 'UFW entry exceeds file bounds')
        payload = data[off:off + length]
        (dest / name).write_bytes(payload)
        entry = {'name': name, 'type': typ, 'index': idx, 'offset': off, 'size': length,
                 'padded_size': padded, 'stored_crc': checksum, 'raw_crc': crc16(payload),
                 'sha256': sha256(payload)}
        # Some metadata entries have an additional encoding layer. Raw CRC is
        # meaningful for the flash payloads and OTA data, not all metadata.
        if name.startswith('flash') or name in ('ota.bin', 'tail.bin'):
            require(entry['raw_crc'] == checksum, f'{name}: payload CRC failed')
        result['entries'].append(entry)
    return result


def inspect_bup(data, dest):
    require(data.startswith(b'BigBigWon Upgrade Pack\0'), 'Unexpected BUP magic')
    require(len(data) >= 139, 'Truncated BUP header')
    dest.mkdir(parents=True, exist_ok=True)
    result = {'bup_sha256': sha256(data), 'bup_size': len(data), 'images': []}
    # The following layout is verified for this V41 two-image package only.
    # It is deliberately not advertised as a universal BUP parser.
    pos = 139
    rebuilt = bytearray(data[:pos])
    for idx, nameoff in enumerate((43, 91)):
        name = data[nameoff:nameoff + 48].split(b'\0')[0].decode('ascii')
        require(pos + 4 <= len(data), 'Missing packed-image length')
        packed_size, = struct.unpack_from('<I', data, pos)
        pos += 4
        end = pos + packed_size
        require(end <= len(data), 'Packed image exceeds file bounds')
        chunks = []
        sizes = []
        repacked = bytearray()
        while pos < end:
            require(pos + 8 <= end, 'Truncated block descriptor')
            compressed, raw = struct.unpack_from('<II', data, pos)
            pos += 8
            require(pos + compressed <= end, 'Compressed block exceeds image bounds')
            decoder = zlib.decompressobj()
            chunk = decoder.decompress(data[pos:pos + compressed]) + decoder.flush()
            require(decoder.eof and not decoder.unused_data, 'Invalid zlib block boundary')
            require(len(chunk) == raw, 'Decompressed block size differs from descriptor')
            pos += compressed
            chunks.append(chunk)
            sizes.append({'compressed': compressed, 'raw': raw})
            recompressed = zlib.compress(chunk, 6)
            repacked.extend(struct.pack('<II', len(recompressed), len(chunk)))
            repacked.extend(recompressed)
        require(pos == end, 'Packed image boundary mismatch')
        image = b''.join(chunks)
        path = dest / f'controller-{idx}.ufw'
        path.write_bytes(image)
        info = inspect_ufw(image, dest / f'controller-{idx}-entries')
        info.update({'original_name': name, 'blocks': sizes, 'packed_size': packed_size})
        result['images'].append(info)
        rebuilt.extend(struct.pack('<I', len(repacked)))
        rebuilt.extend(repacked)
    require(pos == len(data), 'Unexpected trailing BUP data')
    result['zlib_level6_roundtrip_byte_identical'] = bytes(rebuilt) == data
    result['roundtrip_sha256'] = sha256(rebuilt)
    (dest / 'inspection.json').write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('bup', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    report = inspect_bup(args.bup.read_bytes(), args.output)
    print(json.dumps({k: v for k, v in report.items() if k != 'images'}, indent=2))
    print('Verified and extracted', len(report['images']), 'UFW images; no firmware changes made.')
