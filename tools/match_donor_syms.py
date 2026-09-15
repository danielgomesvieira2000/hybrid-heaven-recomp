#!/usr/bin/env python3
"""Name Hybrid Heaven's library functions by matching their instruction bodies
against symbol-rich ELFs of other games built on the same libraries.

Naming libultra is not documentation (playbook 03): N64Recomp hands a function
with a libultra name to the runtime. So a name is only proposed when a donor
function's *body* matches, word for word, once the fields a linker fills in are
masked -- never by guessing from call patterns.

Donors are other ports' ELFs on this machine (derived from their own dumps, never
committed, never copied): Beetle Adventure Racing's recomp.elf (libultra 2.0I, the
version Hybrid Heaven's header names), Pilotwings 64's and Wave Race 64's ELFs.
Only names are taken from them.

Masked before comparing: jal/j targets; lui immediates (except hardware-register
pages); the 16-bit immediate of
addiu/ori/loads/stores/float loads and stores whose base register is not $sp or
$zero (%lo relocations). Branch offsets are position-independent and compared.

A match is accepted only if:
  - the normalised body is at least MIN_WORDS words,
  - it occurs exactly once in Hybrid Heaven, and
  - every donor that has that body agrees on one name.

Usage (inside WSL):
    python3 tools/match_donor_syms.py [--write]
Prints matches and conflicts; --write rewrites the generated block of
recomp/symbol_addrs.txt.
"""
import re
import struct
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
HH_ELF = REPO / "elf" / "hybrid-heaven.us.elf"
SYMBOL_ADDRS = REPO / "recomp" / "symbol_addrs.txt"
HOME = Path.home()
DONORS = [
    ("BAR", HOME / "projects/bar-decomp/build/recomp.elf"),
    ("PW64", HOME / "projects/pw64-decomp/build/pilotwings64.us.elf"),
    ("WR64", Path("/mnt/c/Users/Daniel/claude-projects/n64recomp_waverace64/wr64.elf")),
]
MIN_WORDS = 3
# Library names only. Donor game functions can share a short body with one of
# Hybrid Heaven's (Pilotwings' snowDisable, Wave Race's SysUtils_Rand) and a game
# name from another game would be a lie.
LIBRARY_NAME = re.compile(
    r"^(__)?(os|al|gu)[A-Z]|^__os|^__ll_|^__ull_|^(bzero|bcopy|bcmp|memcpy|memset|strlen|strchr|strcmp|sprintf)$"
    r"|^_(Printf|Litob|Ldtob|Genld|Putfld|frexpf|ldexpf|VirtualToPhysicalTask|doModFunc|allocatePVoice"
    r"|collectPVoices|freePVoice|pullSubFrame|decodeChunk|saturate|filterBuffer|loadOutputBuffer|loadBuffer)$"
    r"|^__(allocParam|freeParam|CSP\w+|seq\w+|vs\w+)$|^init_lpfilter$|^(sqrtf|sinf|cosf|sins|coss)$")
# Never named, even when the body matches: the Controller Pak and Rumble Pak
# plumbing. N64Recomp lists these as reimplemented (librecomp answers "no pak")
# or ignored (nothing emitted, so something must implement them). Left unnamed,
# the game's own code runs and reaches the port only through __osSiRawStartDma,
# which the port serves at the joybus level (playbook 05 "Saves"; Rayman 2's
# CONTROLLER-PAK-FINDINGS.md).
NEVER_NAME = re.compile(
    r"^(osPfs|__osPfs|osMotor|__osMotor|__osCont|__osPack|__osSiGetAccess$|__osSiRelAccess$"
    r"|__osSiCreateAccessQueue$|__osCheckPackId$|__osCheckId$|__osGetId$|__osRepairPackId$)")
BEGIN = "// ---- matched by tools/match_donor_syms.py (do not edit this block) ----"
END = "// ---- end matched ----"


def read_elf(path: Path):
    data = path.read_bytes()
    if data[:4] != b"\x7fELF" or data[5] != 2:
        raise SystemExit("%s: not a big-endian ELF" % path)
    e_shoff, = struct.unpack_from(">I", data, 0x20)
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from(">HHH", data, 0x2E)
    shdrs = []
    for i in range(e_shnum):
        name, typ, flags, addr, off, size, link, info, align, entsize = struct.unpack_from(
            ">10I", data, e_shoff + i * e_shentsize)
        shdrs.append(dict(name=name, type=typ, addr=addr, off=off, size=size, link=link, entsize=entsize))
    funcs = []
    for sh in shdrs:
        if sh["type"] != 2:  # SHT_SYMTAB
            continue
        strtab = shdrs[sh["link"]]
        for k in range(sh["size"] // 16):
            st_name, st_value, st_size, st_info, st_other, st_shndx = struct.unpack_from(
                ">IIIBBH", data, sh["off"] + k * 16)
            if st_info & 0xF != 2 or st_size < 4 * MIN_WORDS or st_shndx == 0 or st_shndx >= len(shdrs):
                continue
            name_off = strtab["off"] + st_name
            name = data[name_off:data.index(b"\0", name_off)].decode()
            sec = shdrs[st_shndx]
            if sec["type"] != 1:  # PROGBITS
                continue
            start = sec["off"] + (st_value - sec["addr"])
            words = struct.unpack_from(">%dI" % (st_size // 4), data, start)
            funcs.append((name, st_value, st_size, words))
    return funcs


LOAD_STORE = set(range(0x20, 0x30)) | {0x31, 0x35, 0x37, 0x39, 0x3D, 0x3F}


def normalise(words):
    out = []
    for w in words:
        op = w >> 26
        rs = (w >> 21) & 31
        if op in (0x02, 0x03):
            w &= 0xFC000000
        elif op == 0x0F:
            # Keep hardware-register pages (KSEG1 0xA0000000-0xBFFFFFFF): masked,
            # __osSpSetStatus and osDpSetStatus are the same three words.
            if not 0xA000 <= (w & 0xFFFF) < 0xC000:
                w &= 0xFFFF0000
        elif (op in (0x09, 0x0D) or op in LOAD_STORE) and rs not in (0, 29):
            w &= 0xFFFF0000
        out.append(w)
    return tuple(out)


def main() -> int:
    hh = read_elf(HH_ELF)
    hh_by_body = defaultdict(list)
    for name, vram, size, words in hh:
        hh_by_body[normalise(words)].append((name, vram, size))

    donor_names = defaultdict(lambda: defaultdict(set))   # body -> name -> {donor}
    for tag, path in DONORS:
        if not path.exists():
            print("donor %s missing: %s (skipped)" % (tag, path))
            continue
        for name, vram, size, words in read_elf(path):
            if not LIBRARY_NAME.match(name) or NEVER_NAME.match(name):
                continue
            donor_names[normalise(words)][name].add(tag)

    matches, conflicts, dup = [], [], 0
    for body, names in donor_names.items():
        targets = hh_by_body.get(body)
        if not targets:
            continue
        if len(targets) > 1:
            dup += 1
            continue
        if len(names) > 1:
            conflicts.append((targets[0], {n: sorted(d) for n, d in names.items()}))
            continue
        (name, donors), = names.items()
        matches.append((targets[0], name, sorted(donors)))

    matches.sort(key=lambda m: m[0][1])
    for (hname, vram, size), name, donors in matches:
        print("  0x%08X size 0x%-5X %-32s <- %s" % (vram, size, name, ",".join(donors)))
    for (hname, vram, size), names in conflicts:
        print("  CONFLICT 0x%08X %s: %s" % (vram, hname, names))
    print("matched %d, conflicting donors %d, bodies occurring more than once in HH %d" % (
        len(matches), len(conflicts), dup))

    if "--near" in sys.argv:
        # Proposals only, for a person to verify by reading both bodies: library
        # functions no exact match named, and the Hybrid Heaven function most like
        # each (difflib ratio over normalised words, sizes within 25%).
        import difflib
        named_bodies = {m[0][1] for m in matches}
        wanted = {}
        for body, names in donor_names.items():
            for name, donors in names.items():
                if name not in {m[1] for m in matches}:
                    wanted.setdefault(name, (body, sorted(donors)))
        # Libraries are linked into the resident image (below file 8's address).
        pool = [(n, v, s, normalise(w)) for n, v, s, w in hh
                if v not in named_bodies and v < 0x80107830]
        print("\n== near matches (verify by hand) ==")
        for name, (body, donors) in sorted(wanted.items()):
            best = []
            for hname, vram, size, hb in pool:
                if not 0.75 <= len(hb) / len(body) <= 1.25:
                    continue
                sm = difflib.SequenceMatcher(None, body, hb, autojunk=False)
                if sm.real_quick_ratio() < 0.85 or sm.quick_ratio() < 0.85:
                    continue
                r = sm.ratio()
                if r >= 0.85:
                    best.append((r, vram, size))
            best.sort(reverse=True)
            if best:
                print("  %-28s (%s, %d words) -> %s" % (name, ",".join(donors), len(body),
                      "  ".join("0x%08X/%d %.2f" % (v, s // 4, r) for r, v, s in best[:3])))

    if "--write" in sys.argv:
        text = SYMBOL_ADDRS.read_text() if SYMBOL_ADDRS.exists() else ""
        if BEGIN in text:
            text = text[:text.index(BEGIN)] + text[text.index(END) + len(END):].lstrip("\n")
        block = [BEGIN]
        for (hname, vram, size), name, donors in matches:
            block.append("%s = 0x%08X; // type:func size:0x%X (body = %s)" % (name, vram, size, ",".join(donors)))
        block.append(END)
        SYMBOL_ADDRS.write_text(text.rstrip("\n") + "\n\n" + "\n".join(block) + "\n", newline="\n")
        print("wrote %d names into %s" % (len(matches), SYMBOL_ADDRS.relative_to(REPO)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
