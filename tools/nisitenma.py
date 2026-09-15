#!/usr/bin/env python3
"""Survey Hybrid Heaven's file table: where every file lives, where it loads, and
which files are code.

The game keeps its data in Konami's "Nisitenma-Ichigo" file table (the same
format Mystical Ninja Starring Goemon and Castlevania use): a ROM offset per
file id, with bit 31 marking an LZKN64-compressed file, and a parallel table of
{vram start, vram end} per id. The loader is func_8000469C(id, dest).

Phase 00 measurements (docs/findings/phase-00.md) come from this script.

Usage:
    python tools/nisitenma.py rom.z64                 summary grouped by load address
    python tools/nisitenma.py rom.z64 --list          one line per file
    python tools/nisitenma.py rom.z64 --extract DIR   write decompressed files (git-ignored
                                                      output: never commit it)

Stdlib only. Addresses are for Hybrid Heaven (USA) NHVE, SHA-1
16dbc21620b52deab5c5abf8a309ac60adfbee85; tools/identify_rom.py checks the dump.
"""
import argparse
import collections
import hashlib
import os
import struct
import sys

# ---- facts about this ROM (measured, see docs/GAME-INTERNALS.md) ------------
BOOT_VRAM = 0x80000400
BOOT_ROM = 0x1000
FILE_TABLE_VRAM = 0x80038FE0   # "Nisitenma-Ichigo" magic, then ROM offsets from +0x10
VRAM_TABLE_VRAM = 0x80037C5C   # 8 bytes per id: vram start, vram end
FILE_COUNT = 0x270             # func_8000469C rejects id 0 and id >= 0x271
COMPRESSED = 0x80000000
ASPMAIN_TEXT_ROM = 0x37130
ASPMAIN_TEXT_SIZE = 0xE20
# SHA-1 of the aspMain text Wave Race 64 (USA Rev A) and Pilotwings 64 (USA) ship.
ASPMAIN_KNOWN_SHA1 = "21e05bb9b4b3611e0cc2374c3ad6cc26adf2b385"
# -----------------------------------------------------------------------------

MAGIC = b"Nisitenma-Ichigo"


def v2r(vram: int) -> int:
    return vram - BOOT_VRAM + BOOT_ROM


def be32(buf: bytes, off: int) -> int:
    return struct.unpack_from(">I", buf, off)[0]


def lzkn64_decompress(buf: bytes, off: int) -> bytes:
    """Decompress one LZKN64 stream (as func_80003824 does).

    Header: big-endian u32 = size of the stream including the header.
    Commands: 0x00-0x7F window copy (10-bit distance, (c >> 2) + 2 bytes);
    0x80-0x9F literal run of (c & 0x1F) bytes; 0xA0-0xDF byte repeated
    (c & 0x1F) + 2 times; 0xE0-0xFE zero repeated (c & 0x1F) + 2 times;
    0xFF zero repeated next + 2 times (read from func_80003824 at 0x80003A08).
    A header with any of the top four bits set selects a second, striped format
    (0x80003A7C); no file in the table uses it, so it is refused here.
    """
    size = be32(buf, off)
    if size & 0xF0000000:
        raise ValueError("stream header 0x%08X is not a size" % size)
    end = off + size
    p = off + 4
    out = bytearray()
    while p < end:
        c = buf[p]
        p += 1
        if c < 0x80:
            dist = ((c << 8) | buf[p]) & 0x3FF
            p += 1
            if dist == 0 or dist > len(out):
                raise ValueError("window distance %d at output %d" % (dist, len(out)))
            for _ in range((c >> 2) + 2):
                out.append(out[-dist])
        elif c < 0xA0:
            n = c & 0x1F
            out += buf[p:p + n]
            p += n
        elif c < 0xE0:
            out += bytes([buf[p]]) * ((c & 0x1F) + 2)
            p += 1
        elif c == 0xFF:
            out += bytes(buf[p] + 2)
            p += 1
        else:
            out += bytes((c & 0x1F) + 2)
    return bytes(out)


def looks_like_code(data: bytes) -> tuple:
    """(jr $ra count, addiu $sp,$sp,-N count, is_code). Threshold: 3 of each."""
    n = len(data) & ~3
    words = struct.unpack_from(">%dI" % (n // 4), data, 0) if n else ()
    jr = sum(1 for w in words if w == 0x03E00008)
    prologue = sum(1 for w in words if (w & 0xFFFF8000) == 0x27BD8000)
    return jr, prologue, jr >= 3 and prologue >= 3


def read_files(rom: bytes):
    ft = v2r(FILE_TABLE_VRAM)
    vt = v2r(VRAM_TABLE_VRAM)
    if rom[ft:ft + 16] != MAGIC:
        sys.exit("file table magic not found at ROM 0x%X: not the supported dump" % ft)
    files = []
    for fid in range(1, FILE_COUNT + 1):
        start_word = be32(rom, ft + 0x10 + (fid - 1) * 4)
        end_word = be32(rom, ft + 0x14 + (fid - 1) * 4)
        start = start_word & 0x7FFFFFFF
        end = end_word & 0x7FFFFFFF
        vstart = be32(rom, vt + (fid - 1) * 8)
        vend = be32(rom, vt + (fid - 1) * 8 + 4)
        f = dict(id=fid, rom=start, rom_end=end, compressed=bool(start_word & COMPRESSED),
                 vram=vstart, vram_end=vend, data=b"", error="")
        if end > start:
            if f["compressed"]:
                try:
                    f["data"] = lzkn64_decompress(rom, start)
                except (ValueError, IndexError) as ex:
                    f["error"] = str(ex) or type(ex).__name__
            else:
                f["data"] = rom[start:end]
        f["jr"], f["prologue"], f["code"] = looks_like_code(f["data"])
        files.append(f)
    return files


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("rom")
    ap.add_argument("--list", action="store_true", help="one line per file")
    ap.add_argument("--extract", metavar="DIR", help="write decompressed files to DIR")
    args = ap.parse_args()

    rom = open(args.rom, "rb").read()
    files = read_files(rom)

    nonempty = [f for f in files if f["data"]]
    code = [f for f in files if f["code"]]
    failed = [f for f in files if f["error"]]
    print("== file table (ROM 0x%X, %d ids) ==" % (v2r(FILE_TABLE_VRAM), FILE_COUNT))
    print("  with ROM data      %d (%d compressed)" % (
        len(nonempty) + len(failed), sum(1 for f in nonempty + failed if f["compressed"])))
    print("  decompress errors  %d  %s" % (len(failed), ", ".join(
        "id %d (vram %08X: %s)" % (f["id"], f["vram"], f["error"]) for f in failed)))
    print("  data span in ROM   0x%X-0x%X" % (
        min(f["rom"] for f in nonempty), max(f["rom_end"] for f in nonempty)))
    print("  code files         %d, 0x%X bytes decompressed, %d 'jr $ra'" % (
        len(code), sum(len(f["data"]) for f in code), sum(f["jr"] for f in code)))
    over = [f["id"] for f in code if len(f["data"]) > f["vram_end"] - f["vram"]]
    print("  code files larger than their vram span: %s" % (over or "none"))

    print("\n== code files by load address (shared address = overlays) ==")
    by_vram = collections.defaultdict(list)
    for f in code:
        by_vram[f["vram"]].append(f)
    for v in sorted(by_vram):
        group = by_vram[v]
        ids = ",".join(str(f["id"]) for f in group)
        print("  %08X  %2d file(s)  largest span 0x%06X  jr %5d  ids %s" % (
            v, len(group), max(f["vram_end"] - f["vram"] for f in group),
            sum(f["jr"] for f in group), ids))

    print("\n== non-code files by load region ==")
    regions = collections.Counter("%08X" % (f["vram"] & 0xFFF00000) for f in nonempty if not f["code"])
    for r, n in sorted(regions.items()):
        print("  %s  %d" % (r, n))
    pic = sum(1 for f in nonempty if f["data"][:3] == b"PIC")
    print("  files starting with 'PIC' (image codec): %d" % pic)

    print("\n== empty ids with a vram range (memory regions reserved by id) ==")
    for f in files:
        if not f["data"] and not f["error"] and f["vram_end"] > f["vram"]:
            print("  id %3d  %08X-%08X  (0x%X)" % (f["id"], f["vram"], f["vram_end"], f["vram_end"] - f["vram"]))

    asp = rom[ASPMAIN_TEXT_ROM:ASPMAIN_TEXT_ROM + ASPMAIN_TEXT_SIZE]
    sha = hashlib.sha1(asp).hexdigest()
    print("\n== audio microcode ==")
    print("  aspMain text ROM 0x%X size 0x%X sha1 %s -> %s" % (
        ASPMAIN_TEXT_ROM, ASPMAIN_TEXT_SIZE, sha,
        "identical to Wave Race 64 / Pilotwings 64" if sha == ASPMAIN_KNOWN_SHA1 else "DIFFERENT"))

    if args.list:
        print("\n== files ==")
        for f in files:
            print("  id %3d  rom %06X-%06X %s  vram %08X-%08X  dec %6X  jr %4d  pro %4d  %s%s" % (
                f["id"], f["rom"], f["rom_end"], "C" if f["compressed"] else "-",
                f["vram"], f["vram_end"], len(f["data"]), f["jr"], f["prologue"],
                "code" if f["code"] else "", f["error"]))

    if args.extract:
        os.makedirs(args.extract, exist_ok=True)
        for f in nonempty:
            with open(os.path.join(args.extract, "%03d_%08X.bin" % (f["id"], f["vram"])), "wb") as fh:
                fh.write(f["data"])
        print("\nwrote %d files to %s (derived from the dump: never commit)" % (len(nonempty), args.extract))
    return 0


if __name__ == "__main__":
    sys.exit(main())
