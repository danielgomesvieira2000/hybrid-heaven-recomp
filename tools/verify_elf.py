#!/usr/bin/env python3
"""Phase 01 gate: prove elf/hybrid-heaven.us.elf describes the cartridge.

Byte identity alone is not enough (playbook 02): a symbol detached from its
section links and matches byte for byte, then N64Recomp cannot find it. So this
checks five things and prints every count:

  1. every code segment's loaded bytes equal the expanded image's (which
     tools/unpack_rom.py built from the dump, and whose SHA-1 splat checks)
  2. every symbol whose name encodes its address sits at that address, and every
     $VRAM_$ROM name sits in the segment whose ROM range contains $ROM
  3. no FUNC symbol is ABS
  4. no FUNC symbol has size 0
  5. no two FUNC symbols in one section overlap

Run inside WSL (needs mips-linux-gnu-readelf/objcopy):
    python3 tools/verify_elf.py
"""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ELF = REPO / "elf" / "hybrid-heaven.us.elf"
IMAGE = REPO / "unpacked" / "hh.expanded.z64"
SEGMENTS_JSON = REPO / "unpacked" / "segments.json"
READELF = "mips-linux-gnu-readelf"
OBJCOPY = "mips-linux-gnu-objcopy"

NAME = re.compile(r"^(?:func|D|jtbl)_([0-9A-F]{8})(?:_([0-9A-F]+))?$")


def sections():
    out = subprocess.run([READELF, "-SW", str(ELF)], capture_output=True, text=True, check=True).stdout
    secs = {}
    for line in out.splitlines():
        m = re.match(r"\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)", line)
        if m:
            idx, name, typ, addr, off, size = m.groups()
            secs[int(idx)] = dict(name=name, type=typ, addr=int(addr, 16), size=int(size, 16))
    return secs


def symbols():
    out = subprocess.run([READELF, "-sW", str(ELF)], capture_output=True, text=True, check=True).stdout
    syms = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 8 and parts[0].rstrip(":").isdigit():
            syms.append(dict(value=int(parts[1], 16), size=int(parts[2], 0) if parts[2].startswith("0x") else int(parts[2]),
                             type=parts[3], ndx=parts[6], name=parts[7]))
    return syms


def main() -> int:
    seg = json.loads(SEGMENTS_JSON.read_text())
    image = IMAGE.read_bytes()
    secs = sections()
    by_name = {s["name"]: s for s in secs.values()}
    fail = 0

    # 1. bytes
    segs = [("resident", seg["resident"]["rom"], seg["resident"]["size"], seg["resident"]["vram"])]
    segs += [("file_%03d" % f["id"], f["rom"], f["size"], f["vram"]) for f in seg["files"]]
    wrong_size = wrong_bytes = 0
    with tempfile.TemporaryDirectory() as tmp:
        for name, rom, size, vram in segs:
            s = by_name.get("." + name)
            if s is None:
                print("  MISSING section .%s" % name)
                fail = 1
                continue
            out = Path(tmp) / (name + ".bin")
            subprocess.run([OBJCOPY, "-O", "binary", "--only-section=." + name, str(ELF), str(out)], check=True)
            got = out.read_bytes()
            want = image[rom:rom + size]
            if s["addr"] != vram:
                print("  %s: vram 0x%08X, expected 0x%08X" % (name, s["addr"], vram))
                fail = 1
            if len(got) < size:
                wrong_size += 1
                print("  %s: %d bytes, expected %d" % (name, len(got), size))
            elif got[:size] != want:
                wrong_bytes += 1
                first = next(i for i in range(size) if got[i] != want[i])
                print("  %s: first difference at +0x%X (vram 0x%08X)" % (name, first, vram + first))
            if any(got[size:]):
                wrong_size += 1
                print("  %s: %d non-zero bytes beyond the file" % (name, len(got) - size))
    print("segments checked : %d     wrong size : %d     wrong bytes : %d" % (len(segs), wrong_size, wrong_bytes))
    fail |= bool(wrong_size or wrong_bytes)

    # 2-5. symbols
    syms = symbols()
    # A bss symbol's $ROM is extrapolated past the loaded bytes by its vram
    # offset, so the range a name may fall in runs to the end of the bss.
    spans = {"resident": seg["resident"]["size"] + seg["resident"]["bss_size"]}
    spans.update({"file_%03d" % f["id"]: f["size"] + f["bss_size"] for f in seg["files"]})
    rom_ranges = {s[0]: (s[1], s[1] + spans[s[0]]) for s in segs}
    placed = misplaced = wrong_file = 0
    for sym in syms:
        m = NAME.match(sym["name"])
        if not m or sym["ndx"] in ("UND",):
            continue
        placed += 1
        if sym["value"] != int(m.group(1), 16):
            misplaced += 1
            if misplaced <= 10:
                print("  misplaced %s at 0x%08X" % (sym["name"], sym["value"]))
        if m.group(2) and sym["ndx"] != "ABS" and sym["ndx"].isdigit():
            sec = secs[int(sym["ndx"])]["name"].lstrip(".")
            sec = sec[:-4] if sec.endswith("_bss") else sec
            lo, hi = rom_ranges.get(sec, (None, None))
            if lo is not None and not lo <= int(m.group(2), 16) < hi:
                wrong_file += 1
                if wrong_file <= 10:
                    print("  %s is in .%s (ROM 0x%X-0x%X)" % (sym["name"], sec, lo, hi))
    print("symbols placed   : %d, misplaced %d, in the wrong file %d" % (placed, misplaced, wrong_file))
    fail |= bool(misplaced or wrong_file)

    funcs = [s for s in syms if s["type"] == "FUNC"]
    abs_funcs = [s for s in funcs if s["ndx"] == "ABS"]
    zero = [s for s in funcs if s["size"] == 0 and s["ndx"] != "ABS"]
    print("FUNC symbols     : %d, ABS %d, zero-size %d" % (len(funcs), len(abs_funcs), len(zero)))
    for s in (abs_funcs + zero)[:10]:
        print("    %s ndx=%s size=%d" % (s["name"], s["ndx"], s["size"]))
    fail |= bool(abs_funcs or zero)

    overlaps = 0
    by_sec = {}
    for s in funcs:
        if s["ndx"].isdigit():
            by_sec.setdefault(s["ndx"], []).append(s)
    for lst in by_sec.values():
        lst.sort(key=lambda s: s["value"])
        for a, b in zip(lst, lst[1:]):
            if a["value"] + a["size"] > b["value"]:
                overlaps += 1
                if overlaps <= 10:
                    print("    overlap %s (+0x%X) and %s" % (a["name"], a["size"], b["name"]))
    print("overlapping funcs: %d" % overlaps)
    fail |= bool(overlaps)

    print("\nPHASE 01 GATE %s" % ("NOT MET" if fail else "MET: ELF byte-identical and symbols sound"))
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
