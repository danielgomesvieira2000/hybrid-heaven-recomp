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
1. Calls `osInitialize` (`0x80028B10`).
2. **Spins forever if `osTvType` (`0x80000300`) is 0** (PAL): an NTSC region lock.
3. `osGetMemSize` (`0x8002C0B0`) == `0x400000` → flags `0x80037754`/`0x80037758` = 0, else 1.
4. Creates threads (`osCreateThread`, `0x80028260`).

Boot memory setup at `0x80001314` loads ids 2, 4, 5, 7 and 8, creates the heap, and
calls `0x80133AAC` in file 8.

### What an unattended boot shows (phase 04, 8 MB reported)

| t (s) | Screen | Code files loaded |
|---|---|---|
| 0–8 | KCEO "presents" logo | 8, 55 |
| 9–33 | Expansion Pak screen, "Expansion Pak Enhanced" (a figure on a 3D Expansion Pak) | 24 at `0x801BF1A0`, 55, then 24 again at a heap address |
| 34–50 | night-city intro cinematic, music | — |
| ~52 | title, "PRESS START BUTTON" | — |
| ~88 | attract loop: TV static with "VOL. IIIII" | the sequence then repeats from the logo |

### Menus and the new-game path (`tools/scripts/newgame.txt`)

| Input | Screen |
|---|---|
| START at the title | NEW GAME / CONTINUE / BATTLE MODE / SOUND / RESOLUTION |
| START on NEW GAME | GAME START / DIFFICULTY / EXIT |
| START on GAME START | "Please connect Controller Pak to Controller 1 now. Do not remove Controller Pak." ▼ (the game then detects the pak and reads its ID, inode and note pages) |
| A | "Please connect a Rumble Pak now if you wish to use it. Please push A Button to continue." |
| A | the opening cinematic: Slater waking in a room, a press conference with a mosaic transition, a subway platform, an elevator shaft, a struggle scene. Code files 25 (`0x801BF1A0`), 26 (`0x801E1BE0`), 55 and 100 (`0x8038B7E0`) load |
| A every 3 s, ~6 min | the cinematic ends in a blue capsule room; then **exploration**: the radar HUD top left, the hero in metal corridors. Files 9 (`0x801BF1A0`, evicting 25 and 26), 10 (`0x801E4AA0`), 11 (`0x8021B150`), 13 (`0x802408F0`), 55 and 56 (`0x803757E0`) load at the switch (t≈462 s) and nothing more loads in the next 7 minutes of rooms. *Inferred:* files 9–11 are the exploration engine |

### Memory size

With `osGetMemSize` answering 4 MB (`HH_EXPANSION_PAK=0`) the "Expansion Pak Enhanced" screen is
skipped and the night-city intro starts straight after the logo. The code files loaded to
exploration are the same as with 8 MB (phase 04, run 6). The main menu's RESOLUTION entry was not
yet checked at 4 MB.

### File loads through allocators

`file_load(id, dest)` writes where it is told. Its callers pass allocator pointers, not
table addresses:

| Caller | `dest` |
|---|---|
| `0x80004484` | `align8(*0x801BBC10)`, an arena pointer |
| `0x800044BC` | `align8(*0x80089470)`, a bump allocator that starts at `0x801BF1A0` and is advanced to the returned end |
| `0x800045E8` | `func_8001F290(vram span)`, a heap allocation; afterwards `func_80016EAC(id, dest)` records (id → address) in a table |

For code files the allocators hand out the link address in every case seen so far, except file 24's
second copy through `0x800045E8`, which lands at `0x801FA948` (*inferred:* a data cache; nothing
executes there in a 15-minute run that reaches exploration).

## Timing

The main loop (`func_80001454`) ends each frame in a **frame limiter that polls the clock**
(`0x80001A88–0x80001B18`): `target = func_80133AA0()`, then
`do { elapsed = (osGetTime() − *0x80037760) × 64 / 3000 / *0x8004B908 } while (elapsed < target)`.
It calls nothing that yields. With the port's yield hook the game settles at 29–30 display lists
per 60 VIs in menus, cinematics and the intro (`HH_FRAME_STATS`), i.e. *inferred* a 30 fps
target. Other `osGetTime` uses in the loop (`0x80001854`, `0x80001938`) are one-shot measurements
feeding a game clock (`0x801BBBF0`: a frame counter wrapping at 3600 (`0xE10`), and a minute field).
A 16-iteration and a 262,144-iteration counted delay loop also exist (`0x8001F8E8` in audio init,
`0x80020204` before `alHeapInit`); both are finite and harmless.

## Rendering

Not yet measured. The game has its own letterbox mode and, with an Expansion Pak, "High
Normal" / "High Letterbox" modes (~640×480) (reviews; not measured).

## Audio

Stock `aspMain` (above). The audio manager follows Nintendo's audio-manager sample:
- init `func_8001F8A0` (`osAiSetFrequency`, `alInit`, heap `0x80096AB0` + `0x35000` from
  `alHeapInit` in `func_800201D0`, 3 `AudioInfo` of `0x68` bytes at `0x80091BD8`);
- thread `func_8001FBA8`;
- frame handler `func_8001FD14`.

The frame handler sizes each frame as `(target + 0x100 − osAiGetLength()/4) & 0xFFF0`, raised to a
minimum by an **unsigned** compare at `0x8001FD8C`. A queue deeper than a frame makes that
negative and lets it past; the port patches it to a signed compare. Output rate 44100 Hz (host
queue stats); the task's command list lives in the game's buffer around `0x800BF9F0`.

## Input

`osContStartReadData`/`osContGetReadData` fill a 4-pad `OSContPad` array at `0x8005CE50`, read by
`func_800021B4` into per-pad records at `0x80089474` (buttons, pressed edges, stick; 0x20 bytes
each). Prompts advance on A; the title and menus take START. In exploration the stick turns and moves the hero (phase 04, `tools/scripts/stick-check.txt`). The debug string `ReadControllers`
is at ROM `0x4C418`.

## Saves

Controller Pak, confirmed on the joybus (`HH_PAKTRACE`). After GAME START the game:
1. sends a status query (card present);
2. writes and reads back block `0x400` (identify / bank select);
3. writes `00 01 02 03…` to block 0 and reads it back, a write test;
4. reads the ID block (block 1), the label (block 7), the inode table (blocks `0x08–0x0F`) and the
   note table (blocks `0x18–0x27`);
5. writes the inode backup (blocks `0x10–0x17`) with the same contents several times.

The Rumble Pak is offered at a separate prompt. The game probes the slot repeatedly, from the logos
on: `osMotorInit` (`func_80027D04`: bank `0xFE` must not read back, `0x80` must), `osGbpakInit`-shaped
`func_80031FF0` (`0xFE` must not read back, `0x84` must) and the Controller Pak checks. After each
accepted `osMotorInit` it stops the motor (block `0x600`, `00`).

The save is one note of game code `NHVE`, publisher `0x4134`, named "HYBRID HEAVEN", starting at
page 5 with a chain through most of the pak (phase 05; when it is created is being traced).

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
