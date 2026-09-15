#!/usr/bin/env python3
"""Classify every `jal` in elf/hybrid-heaven.us.elf by what its target is.

A wrong function boundary compiles and corrupts state at run time (playbook 02),
and a call landing inside a function is the cheapest evidence of one. Categories:

  own-start     start of a function in the caller's own section
  global-start  start of a function in the resident image or file 8
  own-mid       inside a function of the caller's own section  -> boundary bug
  global-mid    inside a resident / file-8 function            -> boundary bug
  other-file    in another code file's address range (an overlay window);
                reported with whether any file has a function starting there
  nowhere       in no code file at all                          -> investigate

Writes recomp/auto_funcs.txt entries for own-mid / global-mid targets with
--write (splat then starts a function there on the next split), in the same
$VRAM_$ROM naming the config uses.

Usage (inside WSL):  python3 tools/jal_audit.py [--write] [--list CATEGORY]
"""
import bisect
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from match_donor_syms import read_elf  # noqa: E402  (FUNC symbols with words)

REPO = Path(__file__).resolve().parent.parent
ELF = REPO / "elf" / "hybrid-heaven.us.elf"
SEGMENTS_JSON = REPO / "unpacked" / "segments.json"
AUTO_FUNCS = REPO / "recomp" / "auto_funcs.txt"


def main() -> int:
    seg = json.loads(SEGMENTS_JSON.read_text())
    files = [("resident", seg["resident"]["rom"], seg["resident"]["vram"],
              seg["resident"]["size"], seg["resident"]["text_size"])]
    files += [("file_%03d" % f["id"], f["rom"], f["vram"], f["size"], f["text_size"]) for f in seg["files"]]
    global_names = {"resident", "file_008"}

    # Functions per file, from names ($VRAM_$ROM tells the file).
    import match_donor_syms
    match_donor_syms.MIN_WORDS = 1
    allf = read_elf(ELF)

    def file_of_rom(rom):
        for name, frm, fvram, size, text in files:
            if frm <= rom < frm + size:
                return name
        return None

    per_file = defaultdict(list)   # name -> sorted [(vram, size, fname, words)]
    for fname, vram, size, words in allf:
        parts = fname.rsplit("_", 1)
        try:
            rom = int(parts[1], 16)
        except (IndexError, ValueError):
            rom = None
        owner = file_of_rom(rom) if rom is not None else None
        if owner is None:
            # library-named: resident or file 8 by address
            owner = "resident" if vram < 0x80107830 else "file_008" if vram < 0x801BF1A0 else None
        if owner:
            per_file[owner].append((vram, size, fname, words))
    for lst in per_file.values():
        lst.sort()
    starts = {k: [v[0] for v in lst] for k, lst in per_file.items()}

    def lookup(owner, target):
        lst = per_file.get(owner, [])
        i = bisect.bisect_right(starts[owner], target) - 1 if lst else -1
        if i < 0:
            return None
        vram, size, name, _ = lst[i]
        if target == vram:
            return "start"
        if target < vram + size:
            return "mid"
        return None

    counts = Counter()
    listing = defaultdict(list)
    new_funcs = {}
    for owner, lst in per_file.items():
        for vram, size, name, words in lst:
            for k, w in enumerate(words):
                if w >> 26 != 3:
                    continue
                target = ((vram + 4 * k) & 0xF0000000) | ((w & 0x3FFFFFF) << 2)
                site = vram + 4 * k
                kind = lookup(owner, target)
                if kind:
                    cat = "own-" + kind
                else:
                    kind = None
                    for g in global_names:
                        if g != owner:
                            kind = kind or lookup(g, target)
                    if kind:
                        cat = "global-" + kind
                    else:
                        others = [f for f in per_file if f != owner and f not in global_names
                                  and lookup(f, target) is not None]
                        in_range = any(fv <= target < fv + fs and n != owner for n, fr, fv, fs, ft in files)
                        if others or in_range:
                            starting = [f for f in others if lookup(f, target) == "start"]
                            cat = "other-file" + (" (starts in %d)" % len(starting) if starting else " (no start)")
                        else:
                            cat = "nowhere"
                counts[cat.split(" (")[0] + (" no-start" if "no start" in cat else "")] += 1
                listing[cat.split(" (")[0]].append("0x%08X in %s -> 0x%08X  %s" % (site, name, target, cat))
                if cat in ("own-mid", "global-mid"):
                    tgt_owner = owner if cat == "own-mid" else next(
                        g for g in global_names if lookup(g, target) == "mid")
                    frow = next(f for f in files if f[0] == tgt_owner)
                    new_funcs[target] = "func_%08X_%X" % (target, frow[1] + (target - frow[2]))

    total = sum(counts.values())
    print("jal instructions: %d" % total)
    for cat, n in sorted(counts.items()):
        print("  %-24s %6d" % (cat, n))
    if "--list" in sys.argv:
        cat = sys.argv[sys.argv.index("--list") + 1]
        for line in listing.get(cat, [])[:200]:
            print("   ", line)
    if "--write" in sys.argv and new_funcs:
        existing = AUTO_FUNCS.read_text() if AUTO_FUNCS.exists() else ""
        lines = [l for l in existing.splitlines() if l.strip()]
        have = {l.split("=")[0].strip() for l in lines}
        added = 0
        for target, name in sorted(new_funcs.items()):
            if name not in have:
                lines.append("%s = 0x%08X; // type:func (jal target inside a function)" % (name, target))
                added += 1
        AUTO_FUNCS.write_text("\n".join(lines) + "\n", newline="\n")
        print("added %d functions to %s" % (added, AUTO_FUNCS.relative_to(REPO)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
