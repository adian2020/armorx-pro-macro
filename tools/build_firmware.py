#!/usr/bin/env python3
"""Report missing firmware integration; never emit an unimplemented patch."""
import json
from pathlib import Path


def main():
    root = Path(__file__).resolve().parent.parent
    status = json.loads((root / 'firmware-status.json').read_text())
    missing = [name for name, ready in status['verified'].items() if not ready]
    if missing:
        raise SystemExit('Firmware not generated. Incomplete integration:\n' +
                         '\n'.join('- ' + name for name in missing))
    # Flags are documentation, not a substitute for implemented patch logic.
    raise SystemExit('Firmware patch/link/repack backend is not implemented; status flags cannot enable it.')


if __name__ == '__main__':
    main()
