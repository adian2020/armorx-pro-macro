#!/usr/bin/env python3
"""Read-only audit of the exact V41 image; emits candidates, never patches."""
import argparse
import hashlib
import json
import re
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / 'original/app.bin'
EXPECTED = '302a700be0a5b351b05c7d42d0bf5e5019f2c0fe2dc524eb390cfd2fae16390b'
BASE = 0x01e00120


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app', type=Path, default=APP)
    parser.add_argument('--asm', dest='assembly', type=Path, default=ROOT / 'original/app-q32s.asm')
    parser.add_argument('--output', type=Path, default=ROOT / 'build/integration-audit.json')
    args = parser.parse_args()
    binary = args.app.read_bytes()
    digest = hashlib.sha256(binary).hexdigest()
    if digest != EXPECTED:
        raise SystemExit('Unexpected application SHA256; do not use these addresses.')
    instructions = []
    for line in args.assembly.read_text().splitlines():
        match = re.match(r'\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}\s)+)\s*(.*)', line)
        if not match:
            continue
        address = int(match[1], 16)
        if address >= 0x01e24500:
            continue
        raw = bytes.fromhex(match[2])
        offset = address - BASE
        if binary[offset:offset + len(raw)] != raw:
            raise SystemExit(f'Disassembly mismatch at {address:#x}')
        instructions.append({'address': hex(address), 'offset': offset,
                             'bytes': raw.hex(), 'asm': match[3].strip()})

    candidates = []
    for insn in instructions:
        a, text = int(insn['address'], 16), insn['asm']
        category, change = None, None
        if re.search(r'= 0x3120$', text):
            category, change = 'config_base', 'Replace with an allocated/verified relocated base; not a guessed SRAM address.'
        elif re.search(r'= 0x3d6[48]$', text):
            category, change = 'config_tail_pointer', 'Use relocated_base + 0x1544 or +0x1548.'
        elif 0x01e05900 <= a < 0x01e0e800 and re.search(r'(= 0xdc$|\+ 0xdc$|\+\+= 0xdc)', text):
            category, change = 'macro_stride_candidate', 'Review use of 220; storage stride/capacity becomes 412. Not every literal is a stride.'
        elif 0x01e05500 <= a < 0x01e17000 and re.search(r'(= 0xc50$|\+ 0xc44$|= 0xc4[4-9a-f]$)', text):
            category, change = 'whole_config_size_or_tail', 'Object size 0xc50 -> 0x1550; tail offset 0xc44 -> 0x1544; mode byte 0xc48 -> 0x1548.'
        if category:
            candidates.append(dict(insn, category=category, required_change=change))

    fixed = {
        0x01e05ad0: 'Profile parameter selection: index*1024 -> index*1792.',
        0x01e05bc2: 'Review another profile index shift by 10; dataflow must confirm ownership.',
        0x01e05e1e: 'Profile macro selection: index*1024 -> index*1792.',
        0x01e091e8: 'Factory reset profile index: requires full loop rewrite/review.',
        0x01e09202: 'Factory reset uses a hardcoded 0x400 increment; cannot mechanically replace without loop analysis.',
        0x01e09208: 'Factory reset uses a 0x1000 termination constant; review with profile and slot indices.',
        0x01e09f3c: 'Macro-mask scan endpoint 6+4*220 -> 6+4*412 (0x676).',
        0x01e0d59e: 'Recorder count comparison: 35 -> 67.',
        0x01e0d626: 'Penultimate/full-slot path: 34 -> 66; preserve final-release handling.',
        0x01e0db1a: 'Execution count clamp: 35 -> 67.',
        0x01e0db1c: 'Execution byte threshold: 215 -> 407 (67*6+5).',
        0x01e06fd4: 'Save block loop extent: original object size/16 bound changes.',
        0x01e16936: 'Load/CRC block loop extent: original object size/16 bound changes.'
    }
    by_address = {int(i['address'], 16): i for i in instructions}
    for address, reason in fixed.items():
        if address not in by_address:
            raise SystemExit(f'Missing expected instruction {address:#x}')
        candidates.append(dict(by_address[address], category='specific_dataflow_review', required_change=reason))

    # Independent verification against the nibble table used by V41's macro CRC.
    table = struct.unpack_from('<16H', binary, 0x01e29900 - BASE)
    for nibble in range(16):
        c = nibble
        for _ in range(4):
            c = (c >> 1) ^ (0xa001 if c & 1 else 0)
        if c != table[nibble]:
            raise SystemExit('Unexpected firmware macro CRC table')

    result = {
        'status': 'OFFLINE_CORE_ONLY_NOT_FLASHABLE', 'original_sha256': digest,
        'target': 'Three profiles, four independent macros each; 67 six-byte records per macro.',
        'old': {'records': 35, 'slot': 220, 'profile': 1024, 'profiles_image': 3072,
                'object_prefix': 68, 'object_suffix': 12, 'object_size': 3152},
        'prototype': {'records': 67, 'slot': 412, 'profile': 1792, 'profiles_image': 5376,
                      'object_prefix': 68, 'object_suffix': 12, 'object_size': 5456,
                      'additional_profile_ram': 2304,
                      'heap_allocation_if_legacy_static_object_is_retained': 5456},
        'unsafe_in_place_window': {'base': '0x3120', 'new_end_exclusive': hex(0x3120 + 5456),
                                  'existing_address_references_inside_growth': ['0x41b8', '0x41bc', '0x4288', '0x45bc']},
        'firmware_macro_crc_table_confirmed': True,
        'trailer_length_encoding': {
            'record_length': 12, 'stored_bytes': '00 0c',
            'q32s_halfword_immediate': '0x0c00',
            'preserve_metadata_length_instructions': ['0x1e05e7e', '0x1e0972a', '0x1e09c1a', '0x1e09ca8', '0x1e09d78', '0x1e0b1f0'],
            'note': 'Do not globally replace 0x0c00 with a new configuration-array byte count.'
        },
        'unresolved': [
            'Available runtime heap and a verified allocation/initialization path.',
            'Complete config-base/interior-pointer relocation, including possible RAM-resident code.',
            'Factory reset and all profile/slot iteration semantics.',
            'A4 original capacities confirmed as 256/328/256/256 bytes; runtime buffer migration and D8/D9 long-payload interoperability remain unimplemented.',
            'USERIF reserved area ownership, old-data migration, metadata CRC and interrupted-save recovery.',
            'Hook/branch relocation and helper integration; container backend supports verified 4096-byte application growth across all eight Flash variants, but updater tail semantics remain unverified.',
            'On-device recording, playback, restart and cross-profile validation.'
        ],
        'candidates': sorted(candidates, key=lambda x: int(x['address'], 16)),
        'candidate_list_is_complete': False
    }
    out = args.output
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(f'Original identity and {len(candidates)} instruction candidates checked against bytes.')
    print('Macro CRC matches V41 nibble table. Firmware output intentionally not implemented: unresolved integration above.')


if __name__ == '__main__':
    main()
