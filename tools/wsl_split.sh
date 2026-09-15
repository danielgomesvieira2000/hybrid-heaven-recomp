#!/usr/bin/env bash
# Phase 01: split the expanded image into assembly with splat.
#
# Produces asm/ (per-function .s), recomp/hybrid-heaven.us.ld (the linker script)
# and the auto-symbol lists. All of it is derived from the builder's own dump and
# is git-ignored; nothing here is committed. Needs unpacked/hh.expanded.z64
# (python tools/unpack_rom.py rom.z64).
set -euo pipefail

VENV="${VENV:-$HOME/hhvenv}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

if [ ! -f unpacked/hh.expanded.z64 ]; then
    echo "unpacked/hh.expanded.z64 missing -- run: python tools/unpack_rom.py rom.z64" >&2
    exit 1
fi

rm -rf asm
echo "=== splat ==="
"$VENV/bin/python" -m splat split recomp/hybrid-heaven.us.yaml "$@" 2>&1 \
    | grep -vE 'it/s\]|s/it\]' || true

echo
echo "=== output ==="
echo "asm .s files    : $(find asm -name '*.s' 2>/dev/null | wc -l)"
echo "function labels : $(grep -rho '^glabel [A-Za-z_][A-Za-z0-9_]*' asm 2>/dev/null | wc -l)"
echo "linker script   : $(wc -l < recomp/hybrid-heaven.us.ld 2>/dev/null || echo missing) lines"
