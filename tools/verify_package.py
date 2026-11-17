"""Verify V41 nested containers and replacements in memory; emit a JSON report."""
import argparse
import json
from pathlib import Path

from tools.audit_original import EXPECTED
from tools.firmware_container import BupPackage
from tools.inspect_bup import require, sha256

EXPECTED_BUP = '80eeaf1fe07ed8150cf288a3e0e522cab818ca46e3a13c0adc41f2235b08cc90'


def verify(raw, exercise_replacement=False, growth=0):
    require(sha256(raw) == EXPECTED_BUP, 'Unexpected original V41 BUP SHA256')
    package = BupPackage(raw)
    app = package.images[0].flashes['flash.bin'].file('app.bin')
    require(sha256(app) == EXPECTED, 'Unexpected original application SHA256')
    require(all(sha256(f.file('app.bin')) == EXPECTED
                for im in package.images for f in im.flashes.values()),
            'Application identity differs among images')
    require(package.rebuild() == raw, 'Full nested stock roundtrip differs')
    result = {'status': 'OFFLINE_CONTAINER_VERIFIED_NOT_FLASHABLE',
              'bup_sha256': sha256(raw), 'full_nested_roundtrip_byte_identical': True,
              'images': [image.report() for image in package.images],
              'in_memory_replacement_verified': False,
              'firmware_runtime_integration_complete': False}
    if exercise_replacement:
        # This byte change tests CRC propagation ONLY. Never output it as firmware.
        changed = bytearray(app)
        changed[0x1000] ^= 1
        modified = package.rebuild(changed)
        parsed = BupPackage(modified)
        require(all(f.file('app.bin') == changed for image in parsed.images
                    for f in image.flashes.values()), 'Application replacement differs')
        for old_image, new_image in zip(package.images, parsed.images):
            for old_entry, new_entry in zip(old_image.entries, new_image.entries):
                require((old_entry.name, old_entry.offset, old_entry.size, old_entry.allocation) ==
                        (new_entry.name, new_entry.offset, new_entry.size, new_entry.allocation),
                        'Replacement changed container layout')
                if old_entry.name not in old_image.flashes:
                    require(old_image.payload(old_entry) == new_image.payload(new_entry),
                            'Replacement changed non-Flash entry')
            for name, old_flash in old_image.flashes.items():
                new_flash = new_image.flashes[name]
                require(old_flash.file('cfg_tool.bin') == new_flash.file('cfg_tool.bin'),
                        'Replacement changed cfg_tool')
                require(old_flash.report()['reservations'] == new_flash.report()['reservations'],
                        'Replacement changed reservations')
        require(parsed.rebuild(app) == raw, 'Reverse replacement did not restore original BUP')
        result['in_memory_replacement_verified'] = True
        result['replacement_experiment'] = {
            'changed_app_offset': '0x1000', 'changed_bytes': 1, 'flash_variants_checked': 8,
            'crc_chain_recomputed_and_reparsed': True,
            'inverse_replacement_restores_original_bup': True,
            'modified_binary_written': False,
            'does_not_validate_runtime_or_unknown_tail_semantics': True}
    if growth:
        require(growth > 0 and growth % 32 == 0, 'Growth must be a positive multiple of 32')
        # Pattern bytes exercise packaging bounds, not executable helper code.
        expanded = app + bytes((i % 251 for i in range(growth)))
        grown = BupPackage(package.rebuild(expanded, grow=True))
        for old, new in zip(package.images, grown.images):
            require(old.auxiliary == new.auxiliary, 'Relocated auxiliary content changed')
            for name, original in old.flashes.items():
                updated = new.flashes[name]
                require(updated.file('app.bin') == expanded, 'Expanded app differs')
                require(original.file('cfg_tool.bin') == updated.file('cfg_tool.bin'),
                        'Expanded image changed cfg_tool')
                require(original.report()['reservations'] == updated.report()['reservations'],
                        'Expanded image changed physical reservations')
                for a, b in zip(original.blocks[1:], updated.blocks[1:]):
                    require(original.plain[a.header_offset:a.header_offset + a.size] ==
                            updated.plain[b.header_offset:b.header_offset + b.size],
                            'Expanded image changed resource')
            for name in ('ota.bin', 'tail.bin'):
                a = next(e for e in old.entries if e.name == name)
                b = next(e for e in new.entries if e.name == name)
                require(old.payload(a) == new.payload(b), 'Expanded image changed ' + name)
        result['growth_experiment'] = {
            'extra_application_bytes': growth, 'flash_variants_checked': 8,
            'all_nested_crcs_reparsed': True, 'physical_reservations_preserved': True,
            'auxiliary_relocation_decoding_preserved': True,
            'configuration_and_secondary_cpu_preserved': True,
            'modified_binary_written': False,
            'runtime_and_tail_semantics_unverified': True}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('bup', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--exercise-replacement', action='store_true')
    parser.add_argument('--exercise-growth', type=int, default=0, metavar='BYTES')
    args = parser.parse_args()
    report = verify(args.bup.read_bytes(), args.exercise_replacement, args.exercise_growth)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    print('Verified 2 UFW images / 8 Flash variants; full nested roundtrip is byte-identical.')
    print('In-memory replacement:', report['in_memory_replacement_verified'])
    print('Report:', args.output, '(no modified firmware file emitted)')


if __name__ == '__main__':
    main()
