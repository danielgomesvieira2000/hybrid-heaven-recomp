# Hybrid Heaven internals

What the game turned out to be. It is written for anyone working on this port, on a
decompilation, or on another port of a game on the same Konami engine family (Mystical
Ninja Starring Goemon and Castlevania use the same file table). Names are `func_XXXXXXXX` /
`D_XXXXXXXX` placeholders, which are also addresses; no decompilation exists. How the port
deals with each fact is in [PORTING.md](PORTING.md); how it was found is in
[findings/](findings).

Conventions: every number names the tool or switch that measures it; refuted hypotheses
are kept; inference is marked *inferred*.

## Identity

| | |
|---|---|
| Title | Hybrid Heaven (USA), game code `NHVE`, version 0 |
| SHA-1 | `16dbc21620b52deab5c5abf8a309ac60adfbee85` (`tools/identify_rom.py`) |
| XXH3-64 | `0x0F6A72F2C36A216D` (what librecomp checks) |
| Header CRC | `0x102888BF 0x434888CA` |
| Entry point | `0x80000400` |
| libultra | *inferred* 2.0I (header `+0xC` = `0x00001449`) |
| Save type | Controller Pak: the game calls `osPfsIsPlug` (0x8002A7D0, from 0x8000281C). Rumble Pak per databases (not yet traced in code) |
| Players | 2 (mupen64plus database; not yet confirmed in code) |
| Expansion Pak | optional; boot compares the memory size with `0x400000` |
| Graphics microcode | F3DEX2 fifo 2.06 (string at ROM `0x4E228`) |
| Audio microcode | stock `aspMain`, text ROM `0x37130` size `0xE20`, byte-identical to Wave Race 64 / Pilotwings 64 (`tools/nisitenma.py`); command table at ROM `0x4E520` |

## Memory layout

| Region | ROM → VRAM | Notes |
|---|---|---|
| Resident image | `0x1000–0x4E7D0` → `0x80000400–0x8004DBD0` | CPU code `0x80000400–0x800350C0` (game code, then libultra from ~`0x80026300`); `rspboot` at `0x800350C0`, graphics microcode text, `aspMain` text at `0x80036530`, then data |
| Resident bss | → `0x8004DBD0–0x800CE990` | cleared by the entry stub; boot `$sp = 0x80057BD0` |
| File id 2 (no data) | → `0x800CE9C0–0x800F41C0` | reserved region |
| File id 4, 7 (no data) | → `0x800F41C0–0x80107830` | reserved regions |
| File id 8 (engine code) | `0x4E69A8–0x53C77C` (LZKN64) → `0x80107830–0x801BF1A0` | loaded once at boot; resident code calls it directly |
| Heap | `0x801BF1A0–0x8038F800` | `func_8001F204(start, size)` at boot; the overlay windows below lie inside it (*inferred:* overlays are placed at fixed addresses within it) |
| Overlay windows | `0x801BF1A0`, `0x801E1BE0`, `0x801E4AA0`, `0x8021B150`, `0x802408F0`, `0x80358820`, `0x803757E0`, `0x803837E0`, `0x8038B7E0`, `0x8038CFC0` | see the file table |
| File id 5 (no data) | → `0x8038F800–0x80400000` | reserved region |
| File id 6, 3 (no data) | → `0x80400000–0x80796000` | Expansion Pak memory: **nothing above 4 MB is free** |

The resident code calls into file 8 at 25 sites (`0x80116E80–0x801521C8`). The TLB routines
(`func_8003049C`, `func_80033C6C`, `func_8002AB94`) have no JAL caller anywhere.

## The file table ("Nisitenma-Ichigo")

| Item | Value |
|---|---|
| Offset table | `0x80038FE0` (ROM `0x39BE0`): magic `Nisitenma-Ichigo`, then from `+0x10` one BE u32 ROM offset per id. File *id* spans entries `id−1` and `id`. **Bit 31 of the start entry = LZKN64-compressed** |
| Vram table | `0x80037C5C`: 8 bytes per id, `{vram start, vram end}` (end includes bss) |
| Ids | 1..`0x270`; `func_8000469C` rejects 0 and ≥ `0x271` |
| Loader | `func_8000469C(id, dest)`: compressed → `func_80003824(rom, dest, size)`, raw → `func_80001FE8`; the rest of the function is not yet read |
| Files with data | 547 (482 compressed), ROM `0x4E5F40–0xE705D2` |
| Code files | 91, `0x368070` bytes decompressed, 15,782 `jr $ra` |
| Image files | 47 at segment `0x08`, all beginning `PIC` (the game's image codec; strings `PIC: decode overrun`) |
| Other data | 398 at segment `0x03`, 7 at `0x04`, 2 at `0x0D` |

Code files by load address (`python tools/nisitenma.py rom.z64`):

| vram | ids | largest span |
|---|---|---|
| `0x80107830` | 8 | `0xB7970` |
| `0x801BF1A0` | 9, 24, 25 | `0x25900` |
| `0x801E1BE0` | 26–53 | `0x27260` |
| `0x801E4AA0` | 10 | `0x366B0` |
| `0x8021B150` | 11 | `0x257A0` |
| `0x802408F0` | 12–22, 54 | `0x1D540` |
| `0x80358820` | 57 | `0x347A0` |
| `0x803757E0` | 56 | `0x151F0` |
| `0x803837E0` | 55 | `0xA5F0` |
| `0x8038B7E0` | 100 | `0x29C0` |
| `0x8038CFC0` | 58–98 | `0x11F0` |

### LZKN64 (from `func_80003824`)

Header: BE u32 stream size including the header (top four bits set = a second, striped
format at `0x80003A7C`, unused by the table).

| Command | Meaning |
|---|---|
| `0x00–0x7F` | copy from output: distance `((c << 8) \| next) & 0x3FF`, length `(c >> 2) + 2` |
| `0x80–0x9F` | `c & 0x1F` literal bytes |
| `0xA0–0xDF` | next byte × `(c & 0x1F) + 2` |
| `0xE0–0xFE` | zero × `(c & 0x1F) + 2` |
| `0xFF` | zero × `next + 2` |

### Per-file layout (measured, `tools/unpack_rom.py` → `unpacked/segments.json`)

Every code file is text, zero padding, data, then bss up to its table end. Text ends just past the last
`jr $ra` (no prologue after it in any file); the padding up to the next multiple of 16 is zero in every
file. Largest files: 8 (text `0x4B840`, data `0x3E4B0`, bss `0x2DC80`), 10 (text `0x320D0`), 57 (text
`0x2CCB0`). The 41 small files at `0x8038CFC0` are about `0xA00` bytes of text each with about `0xA0`
of data.

### Calls between files

Overlays call functions in other overlays' windows directly (`jal`), 15,251 sites. For example, file 26
(`0x801E1BE0`) calls into files 99/100 (`0x8038B…`) and 24/25 (`0x801C0B8C`), so windows are loaded
together in combinations the code assumes. 0 calls land mid-function; every cross-window target starts
a function in at least one file (`tools/jal_audit.py`).

## libultra

Version 2.0I (header; bodies identical to Beetle Adventure Racing's 2.0I libultra). Resident, from about
`0x80026300` to `0x800350C0`, with the audio library (`al*`) and `gu*` mixed in. 147 names with
evidence: `recomp/symbol_addrs.txt`. Addresses of note:

| Address | Name | Note |
|---|---|---|
| `0x800270B0` / `0x800270C0` | `__osExceptionPreamble` / `__osException` | one handwritten routine; preamble is 0x10 bytes |
| `0x80027824` / `0x800279A0` | `__osDispatchThread` / `__osCleanupThread` | |
| `0x80028B10` | `osInitialize` | first call in `main` |
| `0x8002C0B0` | `osGetMemSize` | probes 4→8 MB |
| `0x800283B0` / `0x80028434` | `osContStartReadData` / `osContGetReadData` | pad array `0x8005CE50`, 4 × 6 bytes |
| `0x800294D0` | `__osSiRawStartDma` | the Controller Pak seam |
| `0x8002A7D0` | (osPfsIsPlug, left unnamed) | Pak detection; called from `0x8000281C` |
| `0x8004AED0` / `0x8004AED4` | `__osViCurr` / `__osViNext` | from `osViSwapBuffer` and the framebuffer getters |
| `0x800CBF80` / `0x800CBFC0` / `0x800CBFC1` | `__osContPifRam` / `__osContLastCmd` / `__osMaxControllers` | from `osContStartReadData` |

## The main loop and game states

`main` (`0x80001078`):
1. Calls `func_80028B10` (*inferred* `osInitialize`).
2. **Spins forever if `osTvType` (`0x80000300`) is 0** (PAL): an NTSC region lock.
3. `func_8002C0B0` (*inferred* `osGetMemSize`) == `0x400000` → flags `0x80037754`/`0x80037758` = 0, else 1.
4. Creates threads (`func_80028260`, *inferred* `osCreateThread`).

Boot memory setup at `0x80001314` loads ids 2, 4, 5, 7 and 8, creates the heap, and
calls `0x80133AAC` in file 8.

## Timing

Not yet measured.

## Rendering

Not yet measured. The game has its own letterbox mode and, with an Expansion Pak, "High
Normal" / "High Letterbox" modes (~640×480) (reviews; not measured).

## Audio

Stock `aspMain` (above). Sequence/sound library not identified.

## Input

Not yet measured. The debug string `ReadControllers` is at ROM `0x4C418`.

## Saves

Controller Pak (databases). Not yet measured in code.

## Leads from cheat databases (unverified)

USA, RMG/Project64 `102888BF-434888CA-45.cht`, converted from GameShark codes:

| Address | Claimed meaning |
|---|---|
| `0x8017DC40` (u16) | player health |
| `0x8017DC88` | player level |
| `0x8017E008` | items |
| `0x801CC8C4` | level/battle select |
| `0x8024A0B0` (float) | *probably* player Y |

---

## Keeping this current

This file describes the *game*. When a later change to the port discovers a new address,
table, format or drawing convention -- or corrects one written here -- update this file in
the same commit that makes the change. Facts about N64Recomp, librecomp, ultramodern or
RT64 belong in [PORTING.md](PORTING.md) instead.
