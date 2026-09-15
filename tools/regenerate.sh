#!/usr/bin/env bash
# Phases 01-02 in one command (inside WSL): split, build and verify the ELF,
# audit call targets, recompile. Stops at the first failing stage.
# Needs unpacked/hh.expanded.z64 (python tools/unpack_rom.py rom.z64 on Windows).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"
bash tools/wsl_split.sh | tail -3
bash tools/wsl_build_elf.sh | grep -E 'objects|emitted|data labels'
python3 tools/verify_elf.py | tail -6
python3 tools/verify_elf.py > /dev/null
python3 tools/jal_audit.py
bash tools/recompile.sh
