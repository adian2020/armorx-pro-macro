"""Extract V41 startup RAM initialization and communication buffer evidence."""
import argparse
import json
import struct
from pathlib import Path

from tools.audit_original import BASE, EXPECTED
from tools.inspect_bup import require, sha256


def audit(app):
    require(sha256(app) == EXPECTED, 'Unexpected V41 application SHA256')

    def checked(address, raw):
        data = bytes.fromhex(raw)
        off = address - BASE
        require(app[off:off + len(data)] == data, f'Instruction mismatch at {address:#x}')

    for address, raw in {
        0x1e00132: 'c1ffe0180000', 0x1e00138: 'c2ffe04f0000',
        0x1e00150: 'c1ff20870000', 0x1e00156: 'c2ffe0330000',
        0x1e0016c: 'c0ff40080000', 0x1e00172: 'c1ffb052e301',
        0x1e00178: 'c2ff80080000', 0x1e00192: 'c0ffc0680000',
        0x1e00198: 'c1ff305be301', 0x1e0019e: 'c2ff481e0000',
        0x1e065a2: 'c3ffa0080000', 0x1e065a8: '37fc8800',
        0x1e06634: '1158', 0x1e0663c: '19f20aa0',
        0x1e15718: 'c2ff688a0000', 0x1e1571e: 'c3ff60fb0000',
        0x1e15736: '2008', 0x1e15738: '3108', 0x1e1573a: '97f3b18b',
    }.items():
        checked(address, raw)
    data_rom, data_ram, data_size = 0x1e352b0, 0x840, 0x880
    buffers = []
    for ram, expected in ((0x928, (72, 256, 0x3d70)),
                          (0x934, (72, 328, 0x3e70)),
                          (0x940, (64, 256, 0x3fb8)),
                          (0x94c, (72, 256, 0x40b8))):
        source = data_rom + ram - data_ram
        raw = app[source - BASE:source - BASE + 12]
        fragment, flags, capacity, pointer, assembled, _, _ = struct.unpack('<BBHIHBB', raw)
        require((fragment, capacity, pointer) == expected, 'Unexpected buffer initializer')
        buffers.append({'descriptor_ram': hex(ram), 'initializer_rom': hex(source),
                        'initializer_bytes': raw.hex(), 'max_fragment_field': fragment,
                        'flags': flags, 'capacity': capacity, 'buffer_ram': hex(pointer),
                        'end_exclusive': hex(pointer + capacity),
                        'initial_assembled_length': assembled,
                        'can_hold_412_byte_macro_without_framing': capacity > 412})
    return {
        'original_application_sha256': sha256(app),
        'classification': 'STATIC_EVIDENCE_RUNTIME_ALLOCATION_NOT_VERIFIED',
        'startup': {
            'zeroed_ranges': [{'start': '0x18e0', 'size': 0x4fe0, 'end': '0x68c0'},
                              {'start': '0x8720', 'size': 0x33e0, 'end': '0xbb00'}],
            'data_copy': {'source': hex(data_rom), 'destination': hex(data_ram),
                          'size': data_size},
            'ram_code_copy': {'source': '0x1e35b30', 'destination': '0x68c0',
                              'size': 0x1e48, 'end': '0x8708'}},
        'original_configuration': {'start': '0x3120', 'size': 3152,
                                    'end_exclusive': '0x3d70'},
        'communication_buffers': buffers,
        'reassembly_capacity_check': {'load_address': '0x1e06634',
                                      'reject_address': '0x1e0663c',
                                      'condition': 'new_assembled_length >= capacity',
                                      'length_field_bits': 16},
        'physical_allocator_initialization': {
            'argument_start': '0x8a68', 'argument_end': '0xfb60',
            'span_bytes': 0xfb60 - 0x8a68, 'call_instruction': '0x1e1573a',
            'resolved_pc_relative_call': '0x2106ea0',
            'sdk_reference': 'Jieli-Tech/fw-AC63_BT_SDK cpu/bd19/maskrom_stubs.ld pmalloc_init=0x106ea0',
            'rom_mirror_interpretation': 'SDK address + 0x2000000; static correspondence only',
            'runtime_free_bytes_or_largest_allocation': None,
            'note': 'Zeroed startup range size is not live static allocation size; allocator pages and virtual heap semantics need runtime confirmation.'},
        'relocation_proposal': {
            'implemented_in_firmware': False,
            'new_configuration_heap_bytes': 5456,
            'reusable_legacy_static_bytes_after_successful_migration': 3152,
            'possible_control_bytes': 64,
            'possible_communication_buffers': {'count': 4, 'capacity_each': 512,
                                              'start': '0x3160', 'end_exclusive': '0x3960'},
            'old_storage_reuse_requires': [
                'Every old configuration base/interior reference relocated before reuse.',
                'No active communications while descriptors change.',
                'Configuration migration and initialization complete before publication.',
                'D8/D9 transmission and reassembly tested with expanded payloads.']},
        'unresolved': ['Actual free physical pages and heap under connected/recording load.',
                       'Complete runtime relocation and initialization hook.',
                       'Power-loss-safe extended-format migration and save.',
                       'Windows device diagnostic/recovery transport.']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('app', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.app.read_bytes())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print('V41 RAM initialization and 4 buffer descriptors checked against original bytes.')
    print('Existing 256/328-byte capacities cannot hold a 412-byte expanded macro.')


if __name__ == '__main__':
    main()
