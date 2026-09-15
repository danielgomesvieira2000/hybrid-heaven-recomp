# Phase 00 findings — survey

This is the working record, wrong turns included; it is not rewritten later. Facts that
outlive the phase are also copied into [PORTING.md](../PORTING.md) or
[GAME-INTERNALS.md](../GAME-INTERNALS.md).

**Gate:** not met yet. The survey half is done and written here. The skeleton half
(submodules, a phase-gated CMake tree that builds, `--identify` in the executable) waits for
approval of [PLAN.md](../PLAN.md).

Reproduce with:

```
python tools/identify_rom.py rom.z64
python tools/survey_rom.py rom.z64
python tools/nisitenma.py rom.z64 [--list] [--extract <ignored dir>]
```

## Answer

Hybrid Heaven (USA) is a tractable N64Recomp target, but not a cheap one. **No
decompilation exists**, so symbols come from splat run from scratch (playbook 01, route C).
**Almost all game code is compressed.** Only about 216 KB of code is resident. The other
91 code files (3.4 MB decompressed, 15,782 `jr $ra`) are LZKN64 streams in Konami's
"Nisitenma-Ichigo" file table. They load at fixed addresses, and many share one address, so
this is Wave Race's overlay shape (shared vram, loaded by the game), not Beetle's
relocatable modules.

The audio microcode is byte-identical to Wave Race 64's and Pilotwings 64's. Graphics use
F3DEX2 fifo 2.06, which RT64 lists as "Needs confirmation". The game saves to the
Controller Pak, supports the Rumble Pak and has 2 players (database facts). It reads
`osMemSize` and uses memory above 4 MB when an Expansion Pak is present.

## Measurements

### Identity

| What | How | Result |
|---|---|---|
| Title / cart id / version | header, `identify_rom.py` | `HYBRID HEAVEN USA`, `NHVE`, version 0 |
| Format / size | header magic | big-endian `.z64`, 16 MB (`0x1000000`) |
| SHA-1 | `identify_rom.py` | `16dbc21620b52deab5c5abf8a309ac60adfbee85` |
| MD5 | `identify_rom.py` | `c47e95bb32ab132c41d67bd243f9e02a` |
| **XXH3-64** (what librecomp's `rom_hash` checks) | Python `xxhash.xxh3_64_intdigest` over the `.z64` | `0x0F6A72F2C36A216D` |
| Header CRC1 / CRC2 | header `+0x10` | `0x102888BF 0x434888CA` |
| Entry point | header `+0x8` | `0x80000400` |
| Header libultra field | header `+0xC` | `0x00001449` (*inferred:* 2.0I, `0x14` = 20, `0x49` = `I`) |
| Revisions in existence | No-Intro (libretro-database) | USA has one revision. Europe `NHVP` and Japan `NHYJ` are separate dumps; Japan saves to SRAM |

Target: **USA NHVE**. It is the only USA revision, no decompilation targets any region, and
Japan uses a different save medium.

### Prior art

| Question | Source | Result |
|---|---|---|
| Decompilation of Hybrid Heaven | GitHub search, decomp.dev, readonlymemo N64 decomp/recomp list (Sept 2026) | **none** |
| Existing port / recomp / fork | GitHub, readonlymemo, heldgames | **none**, so start fresh (no fork question for Daniel) |
| Same file-table + compression engine, recompiled | `klorfmorf/Goemon64Recomp` (GPL-3.0) | Mystical Ninja Starring Goemon: N64Recomp, symbols-file mode on a *decompressed* ROM that its decomp builds. A `RECOMP_PATCH` on the file loader calls `recomp_load_overlays(file_rom_addr, buf, size)`. Read for design only |
| Same engine family, decompilations | `klorfmorf/mnsg` (Goemon), `k64ret/cv64` (Castlevania) | **no license published** on either, so names only, never copied |
| LZKN64 tooling | `klorfmorf/lzkn64` | exists; not used (format re-derived from the game's own decompressor, below) |

### Save, accessories, players (database facts, not measured in the ROM)

| Source | Line |
|---|---|
| mupen64plus.ini | `[C47E95BB…] GoodName=Hybrid Heaven (U) [!] … Players=2 SaveType=None Mempak=Yes Rumble=Yes` |
| ares `mia/medium/nintendo-64.cpp` | `if(id == "NHV") {cpak = true; rpak = true;} //Hybrid Heaven (U + E)` |
| Project64.rdb | `[102888BF-434888CA-C:45] … RDRAM Size=8` (the emulator gives it an Expansion Pak) |
| Reviews | Expansion Pak enables optional "High Normal" / "High Letterbox" modes (~640×480, large frame-rate cost) |

The ROM agrees about the Expansion Pak. Boot reads the memory size (below), and the debug
strings `expansion_memory_fg %x` (ROM `0x4C340`) and `hirezoの実験` are present. The
Controller Pak and 2-player claims are *not yet measured* in code; phase 01 names `osPfs*`
and `osContInit`, which settles both.

### Code layout: resident image

| What | How | Result |
|---|---|---|
| Entry stub | disassembly at `0x80000400` | clears bss `0x8004DBD0`, size `0x80DC0` (to `0x800CE990`); `$sp = 0x80057BD0`; `jr` to `0x80001078` |
| Boot image | entry stub bss start | ROM `0x1000–0x4E7D0` → vram `0x80000400–0x8004DBD0` (code + data) |
| Resident code extent | `jr $ra` / JAL density per 4 KB page (scratch scan) | code ends at ROM ~`0x37000` (vram ~`0x80036400`); after it come RSP microcode and data |
| `survey_rom.py` code blocks | 4 KB blocks >90% plausible MIPS | `0x1000–0x27000`, `0x28000–0x36000` = 208 KB. Its "flat image" JAL scan window (`0x1000–0x45000`) overruns into data: the 700 JAL "targets" at `0x8400xxxx` are data words and RSP code (`rspboot` at ROM ~`0x35CE0` decodes as CPU `mtc0` + `jal 0x8400103C`) |
| Resident function floor | JAL targets inside `0x80000400–0x80036400` | ~950 `jr $ra`; *inferred* ~1,000 functions |
| TLB | `tlbwi` at ROM `0x310C0`, `0x348A8`; `tlbp` at `0x2B7C4` | **no JAL caller** in resident code or any decompressed code file. *Inferred:* libultra linked in and unused; no TLB-mapped code |
| `main` (`0x80001078`) | disassembly | calls `func_80028B10` (*inferred:* `osInitialize`), then **spins forever if `*(0x80000300) == 0`** (`osTvType` PAL). Then `func_8002C0B0` (*inferred:* `osGetMemSize`) compared to `0x400000` sets flags `0x80037754`/`0x80037758` |
| Memory setup (`0x80001314`) | disassembly | `func_8000469C(id, dest)` loads ids 2, 4, 5, 7 and 8 at their table addresses. `func_8001F204(0x801BF1A0, 0x8038F800 - 0x801BF1A0)` sets up a heap; then `jal 0x80133AAC` enters **file 8** |
| Resident calls into loaded code | JALs from resident code to ≥ `0x80040000` | 25 call sites, all into `0x80116E80–0x801521C8`, i.e. file 8 |

### Code layout: the file table

| What | How | Result |
|---|---|---|
| Loader | disassembly of `func_8000469C` | rejects id 0 and id ≥ `0x271`. It reads the ROM offset table at `0x80038FE0 + 0x10`: start = entry id−1, end = entry id, bit 31 of start = compressed. It reads the vram table at `0x80037C5C` (8 bytes per id: start, end). Compressed → `func_80003824(rom, dest, size)`, then `func_80028A90`, `func_80030640`, `func_800306C0` (*inferred:* cache invalidation). Raw → `func_80001FE8` |
| Table magic | ROM `0x39BE0` | `Nisitenma-Ichigo` (Konami's table; same name as in Goemon and Castlevania) |
| Files with ROM data | `nisitenma.py` | 547 of 624 (482 compressed), ROM `0x4E5F40–0xE705D2`; then `0xFF` padding to 16 MB |
| Decompression | `nisitenma.py`, 0 errors | all 482 streams decompress; every code file fits its vram span |
| **Code files** | ≥3 `jr $ra` and ≥3 `addiu $sp,$sp,-N` | **91 files, `0x368070` bytes, 15,782 `jr $ra`** |
| Non-code files | same | 398 at segment `0x03`, 7 at `0x04`, 47 at `0x08` (all start `PIC`: the image codec), 2 at `0x0D` |
| Reserved regions (ids with a vram range and no data) | same | id 2 `0x800CE9C0–0x800F41C0`, id 4 `0x800F41C0–0x800F51C0`, id 7 `0x800F51C0–0x80107830`, id 5 `0x8038F800–0x80400000`, **id 6 `0x80400000–0x80700000`, id 3 `0x80700000–0x80796000`** (Expansion Pak memory) |

Code files by load address (`python tools/nisitenma.py rom.z64`):

| vram | files | largest span | `jr $ra` | ids | shape |
|---|---|---|---|---|---|
| `0x80107830` | 1 | `0xB7970` | 929 | 8 | main engine code, loaded once at boot |
| `0x801BF1A0` | 3 | `0x25900` | 1,337 | 9, 24, 25 | shared-address overlays |
| `0x801E1BE0` | 28 | `0x27260` | 10,104 | 26–53 | shared-address overlays; the bulk of the game |
| `0x801E4AA0` | 1 | `0x366B0` | 430 | 10 | overlaps the `0x801E1BE0` window, so these are alternatives |
| `0x8021B150` | 1 | `0x257A0` | 445 | 11 | |
| `0x802408F0` | 12 | `0x1D540` | 1,372 | 12–22, 54 | shared-address overlays |
| `0x80358820` | 1 | `0x347A0` | 564 | 57 | |
| `0x803757E0` | 1 | `0x151F0` | 220 | 56 | overlaps 57 |
| `0x803837E0` | 1 | `0xA5F0` | 14 | 55 | overlaps 56 |
| `0x8038B7E0` | 1 | `0x29C0` | 115 | 100 | |
| `0x8038CFC0` | 41 | `0x11F0` | 252 | 58–98 | small files, 6 `jr $ra` each (*inferred:* one entity/AI script each) |

Ids 9, 10 and 11 sit end to end (`0x801BF1A0 → 0x801E4AA0 → 0x8021B150 → 0x802408F0`), and
so do ids 12+ after them. So some files form a set loaded together, and others replace one
another at one address. *Inferred* from the addresses; phase 04's load log confirms it.

### LZKN64, read from the game's decompressor (`func_80003824`)

| Command byte | Meaning |
|---|---|
| header (BE u32) | stream size including the header. Any of the top 4 bits set selects a second, striped format (`0x80003A7C`); no file in the table uses it |
| `0x00–0x7F` | window copy: distance `((c << 8) \| next) & 0x3FF`, length `(c >> 2) + 2` |
| `0x80–0x9F` | literal run of `c & 0x1F` bytes |
| `0xA0–0xDF` | next byte repeated `(c & 0x1F) + 2` times |
| `0xE0–0xFE` | zero repeated `(c & 0x1F) + 2` times |
| `0xFF` | zero repeated `next + 2` times |

### Microcode

| What | How | Result |
|---|---|---|
| Graphics | string scan | `RSP Gfx ucode F3DEX       fifo 2.06  Yoshitaka Yasumoto 1998 Nintendo.` at ROM `0x4E228`. The spacing is the F3DEX2 family's, so RT64's entry is `F3DEX2.fifo 2.06` (`lib/RT64/src/gbi/rt64_gbi.cpp:104` at RT64 `5473732`), marked **"Needs confirmation"**. Budget for renderer bugs (playbook 01). *Not yet confirmed* that the string lies inside the task's `ucode_data`; do that in phase 04 |
| Audio | `nisitenma.py` SHA-1 of ROM `0x37130+0xE20` vs Pilotwings 64's `aspMain` text | **identical** (`21e05bb9…`). The 16-entry command table `0x1118, 0x1470, 0x11DC, 0x1B38, …` is found at ROM `0x4E520`, so aspMain data starts at ROM `0x4E510`. Wave Race / Pilotwings RSPRecomp config applies (`text_address 0x04001080`, `text_size 0xE20`) |

### RAM facts from cheat databases (unverified leads for later phases)

From the RMG/Project64 cheat file `102888BF-434888CA-45.cht`: player health `0x8017DC40`
(16-bit); items `0x8017E008`; level/battle select `0x801CC8C4`; *probably* player Y
`0x8024A0B0` (float). No widescreen or 60 fps codes exist. The game has its own letterbox
mode, which is not 16:9.

## Negative results

- **"The ROM is one flat code image"**: `survey_rom.py`'s JAL window reported 549 targets
  inside and 509 outside. The outside ones are data words and RSP code, plus 25 real calls into
  file 8. The code is not flat.
- **"The `0x8400xxxx` JAL targets are a mapped segment"**: they are data and `rspboot`
  decoded as CPU instructions (`mtc0`/`mfc0` on RSP cop0 registers). Nothing maps there.
- **"47 files at `0x08000000` are TLB-mapped code (as in Goemon)"**: all 47 start with the
  `PIC` image-codec magic. None is code.
- **First decompressor**: `0xFF` was read as "byte repeated next + 2 times" (from memory of the
  LZKN64 format). The permissive version produced output for every file, with window distance
  0 silently read as index 0. The strict version then failed 6 streams, and reading
  `0x80003A08` showed that `0xFF` is a *zero* run with no data byte. Now 0 failures. Lesson: a
  decoder that never raises is not evidence it is right.

## Inference

- *Inferred:* libultra 2.0I, from the header field. Confirmed once libultra functions are
  byte-identified in phase 01.
- *Inferred:* shared-address groups are overlays swapped by game state, from the load
  addresses. Confirmed by the phase-04 load log.
- *Inferred:* the game is region-locked to NTSC in `main`, so the runtime must report
  `osTvType = 1`. Confirmed in phase 03 by reading what librecomp writes to `0x80000300`.

## What is not established

- Controller Pak use and player count in code (phase 01, by naming `osPfs*`/`osCont*`).
- Timing model: fixed step, frame-counted or measured (phase 04/08).
- Whether the game still offers the hi-res modes when the runtime reports 8 MB, and what
  they cost (phase 04/05).
- Whether overlay files reference each other's functions directly (JAL into another
  window). That decides `use_lookup_for_all_function_calls` (phase 01–02).
- Whether all 91 code files are reached, and whether any code is loaded outside
  `func_8000469C` (phase 04 load log).
- Busy-wait loops (`find_spin_loops.py`, phase 04).

## Consequence for the plan

- Phase 01 is route C (splat from scratch) plus a local unpack step. Each code file becomes a
  splat segment at its vram, with a synthetic ROM offset in a locally built "expanded image"
  (never committed). The runtime announces a file to librecomp from a wrapper on
  `func_8000469C`, the lowest point every load shares (playbook 04).
- The resident segment has a bss gap and file 8 is placed by the game, so both get
  registered at their linked addresses (playbook 04, "segments the game copies itself").
- Audio: reuse the aspMain RSPRecomp config after re-checking the bytes (done here).
- Saves: Controller Pak → Daniel's N64ModernRuntime fork, `controller-pak` branch
  (series rule).
