# 001 — crash (lookup miss at 0x80379410) in the first-enemy cutscene

**Status:** fixed (commit with this file)

---

## What is wrong

The game closes during the cutscene where the hero meets the first enemy. The log ends in a
lookup miss, not an access violation:

```
[hh] ==== LOOKUP MISS #1 ====
[hh] no function registered at 0x80379410
[hh] code files loaded: 8 9 10 11 13 56
```

## Where

Daniel's own save, CONTINUE from the main menu, walk to the first enemy (2026-09-19). Twice in
two tries. Scripted runs (phases 04, 05, 07: `newgame.txt`, up to 15 min of exploration) never
reached the first encounter, so they never took this path.

## Is it stable?

2 of 2 attempts, same address, same loaded files.

## Evidence

- Load history (`HH_DEBUG_LOADS=1`, second crash): 8, 55, 24, then three rounds of
  24 (link) → 55 → 24 (heap copy at `0x801FA948`), then 9, 10, 11, 13, 55, 56, then the miss.
  Files 25, 26 and 100 (GAME START and the pak prompts in `newgame.txt`) never load: consistent
  with CONTINUE. **File 57 never loads.**
- Caller chain (lookup ring): `0x8021B280`, `0x8022C7A4`, `0x8022C5AC`, `0x8022C314`,
  `0x8022C478` → miss. All file 11.

## Investigation

| Fact | Source |
|---|---|
| `0x80379410` is the start of `func_80379410` in **file 57** (window `0x80358820–0x8038CFC0`) | `asm/file_057.s` |
| In **file 56** (`0x803757E0–0x80389EE0`) the same address is mid-function (`func_80379244`, an `addiu` before a `jal func_800058DC`) | `asm/file_056.s:4228` |
| The call is `jal func_80379410` at `0x8022CAA4` in `func_8022C7A4` (file 11), taken only when byte `D_8017DD92 == 0`. A second site at `0x802326DC` | `asm/file_011.s:20223` |
| `D_8017DD92` is file 8 *data*, initial value 0 | `asm/asm/data/file_008_data.data.s:75820` |
| Its only writer is `func_80152CF8(a0)` (`= a0 + 1`), called once, from `func_801C44C4` in file 24: a two-entry up/down menu (`D_801CC8C8` ∈ {0, 1}) that stores `choice + 1` on confirm. Which menu it is: not identified | `asm/file_024.s:5910` |
| File 8 chooses overlays by scene id `D_801BBC1C` through two jump tables (`0x801256C8`), loading 56 (`0x38`) or 100 (`0x64`) through `func_80004484`; no constant-id load of 57 was found | `asm/file_008.s:32640` |
| `func_801FCBA8(0x39)` in file 9 is a sound call (`func_80020DAC` / `func_800208C4`), not a load of file 57 | `asm/file_010.s:26684` |

So with file 56 in memory the call cannot be meant: on hardware it would run file 56 from the
middle of a function. Either file 57 reaches RDRAM through a path the `file_load` wrapper does not
see, or `D_8017DD92` should be nonzero here (set by a menu or restored from the save) and is not.

The lookup-miss report now prints the RDRAM words at the target and `D_8017DD92` / `D_801BBC1C`
(`src/sections.cpp`, `on_lookup_failure`), which tells the two apart on the next crash.

**Third crash (same route):** `RDRAM at 0x80379410: AFA50004 30A500FF 14A00010 00001025`,
`D_8017DD92 = 0`, scene `0x0004`. Those words occur once in the expanded ROM, at `0x13340E0`: file
57's `func_80379410`. **File 57's code is in RDRAM although `file_load` never saw id 57**, so the
port's function map is what is wrong, not the game's flag.

Ruled out as the path that put it there:

| Path | Why not |
|---|---|
| `file_load` with flag bits in the id | `file_load` rejects id ≥ `0x271`; ids are not masked |
| A direct (non-lookup) call to `file_load` or `lzkn64_decompress` in generated code | none; every call is `LOOKUP_FUNC` |
| `lzkn64_decompress`'s other caller, `func_80022044` | decompresses sound data to fixed buffers `0x801B6600` / `0x801B8600` |
| A raw DMA of file 57 | file 57 is compressed (table entry bit 31) |
| `func_801FCBA8(0x39)` in file 9 | a sound call |

**Fourth and fifth crashes:** the `[hh-lzkn]` trace shows no decompression of file 57 (ROM
`0x69E416`); the RDRAM dump (`HH_MISS_DUMP`) shows **all of file 57** (`0x343A0` bytes) at
`0x80358820`, over files 55 and 56. So a complete decompression happened outside
`lzkn64_decompress`.

## Cause

The game has a second loader. `func_80004838(id, dest)` loads the same file-table entry a piece per
call, through its own resumable LZKN64 decompressor `func_80003F44`, and returns the end address on
the call that completes the file. The load queue streams file 57 with it during the encounter
cutscene. The port wrapped only `file_load`, so file 57's functions were never registered. Found by
searching every function for the decompressor's comparisons (`0x3FF` mask, `slti 0xA0`,
`slti 0xE0`): `func_800036D0`, `lzkn64_decompress`, `func_80003F44`.

## Fix

`src/sections.cpp` wraps `0x80004838` and announces the file on the completing call (`v0 != 0`), the
point where a console could run it. A/B: `HH_NO_STREAMED_LOADS=1`.

Verified by Daniel (2026-09-19): past the first-enemy cutscene and through five battles; the log shows
file 57 announced at each encounter and file 56 on the way back, no lookup miss, clean shutdown.

Not verified: `func_800036D0` (the third decompressor) has no caller found yet.
