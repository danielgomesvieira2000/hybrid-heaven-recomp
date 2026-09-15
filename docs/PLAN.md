# Build plan

The plan this project is executed against. It is written before the work and kept as
written, so the reasoning behind each phase survives. Where the work overturns something
here, add a note under *Departures* rather than rewriting the text. Findings go in
[findings/](findings). Reference facts go in [PORTING.md](PORTING.md) (port) and
[GAME-INTERNALS.md](GAME-INTERNALS.md) (game).

**Status:** phases 00-02 done 2026-09-15. Plan approved by Daniel 2026-09-15 ("looks good, continue autonomously"). The
session runs autonomously: at each choice the recommended option is taken and logged below.

> **Departures from this plan** (added as they happen):
>
> - *Phase 01*: the ELF has **93** code segments (resident + 92 files), not 92: file 99 has one
>   function besides its data. Everything else as planned. ([findings/phase-01.md](findings/phase-01.md))

## Goal

A native PC port of **Hybrid Heaven** for Windows and Linux. It is built with N64Recomp on
N64ModernRuntime and RT64, with the RecompFrontend launcher and menus, and shares the
harness, frontend and dev tooling of Wave Race 64: Recompiled (the series reference build).

Enhancements for the first release:

- **Widescreen:** a genuinely wider view with no edge culling visible, HUD anchored to the
  frame edges, no black bars in any aspect mode.
- **High frame rate:** matrix interpolation in RT64; the game keeps its own update rate.

## Target

| | |
|---|---|
| Game | Hybrid Heaven (USA), game code `NHVE`, version 0 |
| SHA-1 | `16dbc21620b52deab5c5abf8a309ac60adfbee85` |
| XXH3-64 | `0x0F6A72F2C36A216D` |
| Header CRC | `0x102888BF 0x434888CA` |
| Entry point | `0x80000400` |
| Save type | Controller Pak (+ Rumble Pak), no cartridge save |
| Players | 2 (database; confirm in code in phase 01) |
| Expansion Pak | optional; the game reads `osMemSize` and has hi-res modes |

One revision only. Every address in the project is tied to it.

## The decision this project is built on

**No decompilation of Hybrid Heaven exists**, and 94% of its code is LZKN64-compressed
inside the Nisitenma-Ichigo file table. The port therefore uses:

1. **ELF input mode** (playbook 01: never symbols-file mode). The ELF is assembled from
   **splat run from scratch** (playbook 01, route C, as Rayman 2 did).
2. **A local unpack step first.** `tools/unpack_rom.py` decompresses the 91 code files
   (`tools/nisitenma.py` holds the format) into an *expanded image*: the original ROM, with
   each code file's decompressed bytes appended at a stable synthetic offset. splat splits
   that image, so every overlay section in the ELF has a ROM address that identifies it. The
   image is derived from the dump: git-ignored, never committed.
3. **Overlays announced at the game's loader.** A native wrapper on `func_8000469C` (file
   id, destination) calls librecomp's `load_overlays(synthetic_offset, dest, size)` for a
   code file, then runs the game's own load. Resident code and file 8 are registered at
   their linked addresses up front (playbook 04).

Rejected: symbols-file mode on a decompressed ROM, which is what Goemon64Recomp does. It
works for Goemon because Goemon's decomp produces the symbols. Here it would forfeit
reference symbols and single-file MIPS patches for the life of the project (playbook 01).

**Symbol sources and their licenses:**

| Source | License | Use |
|---|---|---|
| splat control-flow analysis + JAL scan of our own image | ours | function boundaries (primary) |
| libultra identified from instruction bodies (playbook 03) | — | names that hand subsystems to the runtime |
| `klorfmorf/mnsg` (Goemon decomp), `k64ret/cv64` (Castlevania decomp): same Konami engine family | **none published** | names only, by matching function bodies. Cloned into `reference/` (ignored); nothing copied into the tree |
| `klorfmorf/Goemon64Recomp` | GPL-3.0 | design reference for the file-loader seam; no code copied into MIT files |

## What is already known about the game

Measured in [findings/phase-00.md](findings/phase-00.md) (`tools/identify_rom.py`,
`tools/survey_rom.py`, `tools/nisitenma.py`):

| Fact | Consequence |
|---|---|
| Resident image ROM `0x1000–0x4E7D0` → `0x80000400`, bss `0x8004DBD0 +0x80DC0`; code ends ~`0x80036400` | ~1,000 resident functions |
| 91 compressed code files, `0x368070` bytes, 15,782 `jr $ra`; groups of up to 41 files share one vram | *estimate* 14–16k functions; WR64-style shared-vram overlays (playbook 04) |
| File 8 (`0x80107830`, engine) loaded once at boot; resident code calls into it directly (25 sites) | register at linked address; direct calls resolve at recompile time |
| No TLB-mapped code; the `0x08000000` files are `PIC` images | no address translation work |
| `main` spins forever unless `osTvType != 0` | runtime must report NTSC |
| Game reads `osMemSize`; files 3 and 6 reserve `0x80400000–0x80796000` | nothing above 4 MB is free scratch; port scratch goes above 8 MB (PW64 used `0x80F00000`) |
| aspMain byte-identical to WR64/PW64 | reuse RSPRecomp config after the byte check (done) |
| Graphics F3DEX2 fifo 2.06, RT64 "Needs confirmation" | budget for renderer bugs in phase 05 |
| Controller Pak + Rumble Pak, 2 players (databases) | Daniel's runtime fork `controller-pak`; 2-player input |

## Decisions

| # | Decision | Options considered | Recommendation | Decided by |
|---|---|---|---|---|
| D1 | ROM revision | USA NHVE / Europe NHVP / Japan NHYJ (SRAM) | **USA NHVE**: the only USA revision; no decomp favours any region | series rule (revision rule) |
| D2 | Fork or fresh | no existing port of this game | **fresh**, modelled on Wave Race | series rule (nothing to fork) |
| D3 | Symbol input | ELF from splat on an expanded image / symbols-file mode (Goemon) | **ELF from splat** (above) | Daniel (plan approval, 2026-09-15) |
| D4 | Name donors | mnsg + cv64 decomps (unlicensed), names only / no donors | **names only, by body matching** | Daniel (plan approval, 2026-09-15) |
| D5 | Runtime / renderer / frontend pins | Daniel's N64ModernRuntime fork `controller-pak` `b0b2b6e` (RAY2) / upstream `cdf5abb` (WR64) + Pak reimplementation | **fork `controller-pak`** (series rule for Pak games), RT64 `5473732` and RecompFrontend `b1a1477` (WR64 pins). Phase 00 verifies the fork builds with those pins and that every stack-patch anchor matches | series rule; compatibility measured in phase 00 |
| D6 | Rumble Pak and Controller Pak | both on one slot (BAR, deliberate hardware deviation) / Pak only, no rumble (RAY2) / pak swap prompt as on hardware | **both on one slot**: saves and rumble with no swap | recommended option, autonomous session (2026-09-15) |
| D7 | Expansion Pak (reported `osMemSize`) | 8 MB (librecomp default; game offers hi-res modes) / 4 MB (standard modes only) | **measure both in phase 04**, keep 8 MB unless hi-res or the extra memory breaks something; RT64 upscales regardless | **8 MB kept** (phase 04: both sizes load the same files and run clean; 4 MB only skips the "Expansion Pak Enhanced" screen). `HH_EXPANSION_PAK=0` stays as a test switch; the hi-res mode is examined at phase 07 | measurement (phase 04); Daniel may override |
| D8 | Identity | — | slug / repo / exe `hybrid-heaven-recomp`; env prefix `HH_`; CMake `HH_WITH_*`; settings `%LOCALAPPDATA%\hybrid-heaven-recomp` (Linux `$XDG_DATA_HOME/hybrid-heaven-recomp`) | series rule |
| D9 | Player count | 1 / 1–2 | **1–2** with WR64/BAR `auto_assign_controllers` patch; keyboard always player 1 | series rule, after phase 01 confirms 2P in code |
| D10 | Public GitHub repo | — | `gh repo create danielgomesvieira2000/hybrid-heaven-recomp --public` | deferred: a public repo is outward-facing and Daniel did not explicitly ask for it; stays local until he does (phase 09 at the latest) |
| D11 | Widescreen / HUD mechanism | MIPS patches against our own names / display-list rewriter (WR64 mechanism, fresh measurements) | decide at phase 07 entry, from what phases 04–06 learn about the draw code | phase 07 |

## Phases

Each phase is entered only through its entry gate. Every phase ends with the tree building;
from phase 03 on, with the game run and looked at. Exit criteria are visible behaviour.

### 00 — Toolchain, survey and skeleton

**Entry:** a legal dump and this plan, approved. *(Survey part already done.)*
**Work:** Repository skeleton from the framework templates. Submodules pinned per D5 (and
re-pinned explicitly, per playbook 01's pin trap). Stack patch scripts copied from
`FW/tools/stack-patches/` into `tools/`, **anchors verified against these submodule
revisions** before running (`python tools/patch_all.py`, idempotent). Phase-gated CMake
(`HH_WITH_RUNTIME`, `HH_WITH_RECOMPILED`, `HH_BUILD_RECOMPILER`, `HH_WITH_FRONTEND`, all
default OFF), clang-cl + Ninja + RelWithDebInfo. `tools/check_toolchain.ps1`. N64Recomp and
RSPRecomp built under WSL (`tools/wsl_build_recompiler.sh`).
**Exit:** `cmake --build build` produces `hybrid-heaven-recomp.exe`, which accepts the dump
with `--identify` and rejects a different dump (Pilotwings 64's). Patch scripts report
"applied" on the first run and "already applied" on the second. Survey written.

### 01 — ROM to ELF

**Entry:** phase 00 exit.
**Work:**
- `tools/unpack_rom.py`: the expanded image, plus a JSON map of file id →
  synthetic offset, vram and size. Stage counts are printed.
- `recomp/hybrid-heaven.us.yaml` from scratch: the resident segment (trailing data declared),
  then one segment per code file at its vram, non-code files excluded.
- splat, assemble and link under WSL. JAL-target scan to convergence (RAY2 `refine-syms.sh`).
- libultra named from instruction bodies. Goemon/CV64 names matched by body (names only).
- `gen_link_syms.py` so no linker assignment shadows an object symbol.
- `verify-elf`: segment bytes vs image, name-encoded symbol placement, `readelf` checks.

**Exit:**
- Every resident and code-file section is byte-identical to the image, with all 92 segments
  checked, 0 wrong size and 0 wrong bytes.
- Every `func_`/`D_` symbol is placed at its own address.
- **0** `FUNC ABS` symbols and **0** zero-size `FUNC` symbols.
- The Controller Pak and controller libultra functions are named, which settles the save medium
  and player count in code.
- `docs/GAME-INTERNALS.md` has the segment map.

### 02 — First recompile

**Entry:** phase 01 exit.
**Work:**
- `recomp/hybrid-heaven.us.toml`; `relocatable_sections_path` lists every shared-vram code
  file.
- Measure whether overlays call each other's windows directly. If they do,
  `use_lookup_for_all_function_calls` via `patch_n64recomp.py` (WR64). If not, direct calls
  suffice.
- `gen_reimplemented_decls.py` over all three built-in lists (playbook 03), then
  `fix_overlay_relocs.py` if out-of-enum relocation types appear.
- `--dump-context` kept for patches. RSPRecomp with the aspMain config (bytes re-checked by
  `nisitenma.py`).
- One regeneration script (`tools/recompile.sh`) that checks its own end state: `funcs.h` ends
  in `#endif`, and the function count matches the ELF.

**Exit:** all of `RecompiledFuncs/` compiles into a static library, with counts reported at
every stage (functions in ELF = functions emitted = functions exported).

### 03 — Runtime harness

**Entry:** phase 02 exit.
**Work:** copy Wave Race's harness literally and change only identity and game facts:
- `main.cpp` with `GameEntry`: `rom_hash 0x0F6A72F2C36A216D`, sign-extended entrypoint,
  `load_stored_rom()`.
- `register_config_path()` → per-user folder.
- Callbacks, crash handler, lookup-miss hook (`patch_librecomp.py`), `timeBeginPeriod(1)`.
- Audio RSP stub that reports completion.
- Own minimal RT64 context behind `HH_WITH_FRONTEND=OFF` (RAY2), so "does the game run" is
  separate from "does the menu init".
- Resident and file-8 registration from `on_init`.
- The `func_8000469C` load wrapper, registered last, with an `HH_DEBUG_LOADS` log.
- The message-queue control set explicitly.
- `osTvType` checked.

**Exit:** a log line from `on_init` and from the first `thread_create_callback`, in **10 of
10** runs (`tools/test_run.ps1`), with no crash in the first 10 s.

### 04 — Boot bring-up

**Entry:** phase 03 exit.
**Work:**
- Crash handler → subtract RDRAM base → name the libultra entry point (playbook 05).
- `tools/find_spin_loops.py` early, with a yield path per wait.
- Lookup misses read with the per-thread indirect-target ring.
- F3DEX2 GBI selected per task; confirm that the graphics ucode string lies inside
  `ucode_data`.
- The load log shows which files load, where and when.
- D7: run with 8 MB and 4 MB reported and record both.

**Exit:** on screen, recognisably:
- the Konami logo, the title screen, the attract sequence;
- **New Game through the opening cutscene into the first controllable scene**.

Also, the load log shows no unknown file id, and no lookup miss occurs in 10 minutes of
scripted play.

### 05 — Graphics, audio and saves correctness

**Entry:** phase 04 exit.
**Work:**
- aspMain via RSPRecomp, with the WR64/PW64 audio output design (queue API, port resampler,
  headroom).
- Controller Pak through the runtime fork's joybus path, a formatted blank pak, and Rumble
  Pak on the same slot per D6.
- Signature effects checked against ares.

**Exit:** a named stretch played start to finish, with correct visuals and audio pitch against
ares, and Daniel confirms: title → New Game → opening cutscene → first battle (the combat
tutorial) → save to the Controller Pak → quit → relaunch → load that save → the game resumes
there. Rumble fires in battle.

### 06 — Frontend

**Entry:** phase 05 exit.
**Work:** copy Wave Race literally (`src/frontend.cpp`, `include/*/frontend.h`, `assets/`
recomp.rcss, icons, promptfont, `tools/patch_recompinput.py`, F1 debug menu + HUD
inspector, relevant CMake blocks). Use `/port-feature` for anything that carries game
measurements.
- The launcher owns Start Game (`add_start_game_or_load_rom_option`, hash-verified);
  `HH_AUTOSTART=1` is opt-in.
- Select opens the menu; Start belongs to the game.
- Keyboard always works for player 1; pads are auto-assigned in connection order (1–2 players).
- Rumble strength slider (0–100%, 0 = off).
- Main Volume applied.
- Mods tab.
- Modest default window (800×600).

**Exit:** Daniel picks his dump in the launcher and plays with a pad, then with the
**keyboard and no pad attached**. Settings survive a restart from another working directory.
F1 opens the debug menu and HUD inspector.

### 07 — Patch pipeline and widescreen

**Entry:** phase 06 exit, and D11 decided.
**Work:**
- MIPS patch pipeline (Clang in WSL; record the version, per the open contradiction in playbook 03).
- Remove borders and overscan, widen the projection, and cull against the widened frustum
  (playbook 08).
- HUD anchoring through the F1 inspector, which Daniel drives. `hud.json` → code via
  `/port-promote-hud`.
- Handle the game's own letterbox and hi-res modes explicitly.

**Exit:** every screen visited in the phase-05 stretch, plus menus and a boss fight, looks right
at 16:9, 21:9 and in a 4:3 window: no black bars, no pop-in at the edges, nothing stretched,
the HUD at the frame edges. Daniel confirms.

### 08 — High frame rate

**Entry:** phase 07 exit.
**Work:**
- Measure the game's update rate per mode (exploration, battle, cutscene).
- Present mode that allows interpolated frames (not `Console`, playbook 09).
- Transform tagging and pairing measured with `patch_rt64_pairing.py`; skip on camera cuts and
  spawns; 2D not interpolated.
- Fix in world space.

**Exit:** smooth motion at 120 Hz+ in exploration, battle and a cutscene with no bursts,
sliding or jitter; a scripted run's game results match the original rate. Daniel confirms,
and the Iris Xe cost is measured.

### 09 — Linux, packaging, first release

**Entry:** phase 08 exit.
**Work:**
- `tools/setup_linux.sh`, `tools/build_linux.sh`.
- Packaging (`tools/package_release.ps1` / `.py`, `-debug-symbols` variants).
- README, BUILDING, CHANGELOG, THIRD_PARTY_NOTICES.
- GitHub repo per D10; release via `/port-release`.
- Register in `FW/ports.md`; `/port-retro`.

**Exit:** a clean clone builds on Windows and under WSL Linux with the documented commands,
the Linux build runs, the packages contain no game data, and a full release is marked
Latest.

### After 1.0 — coverage and hardening

Soak runs, the rest of the game played, draw distance and similar settings in the Graphics
tab. Work continues without new phase numbers; the changelog records it.

## Testing throughout

- Build after every change; never leave the tree not building.
- From phase 03, run the game after every behavioural change and look at it: scripted input
  (`HH_INPUT_SCRIPT`), `tools/capture_frames.py`, the log in the settings folder.
- Close any running instance before rebuilding; leave nothing running.
- Test scripts back up and restore the user's config files.
- A regression found is written in the findings before it is fixed.

## What would make this project stop

Stated in advance, so the decision is not made under sunk cost:

- Phase 01 cannot make all 91 code files and the resident image byte-identical in the ELF.
- Code executes that is not in the file table and cannot be registered: generated at run
  time, or copied from data.
- RT64's F3DEX2 fifo 2.06 path is substantially broken for this game, beyond a scoped
  renderer fix.

## Standing constraints

- **No ROM, ELF, expanded image, extracted or derived asset is ever committed.** Game facts
  (addresses, formats) go in docs; bulk data does not.
- **Generated code is never hand-edited.** Fix the config, a patch, or a script in `tools/`.
- **Submodules are never hand-edited.** Every change is an idempotent `tools/patch_*.py`, with
  its anchors verified against the pinned revision.
- **Docs in the same commit:** game facts in GAME-INTERNALS.md, port facts in PORTING.md,
  findings as they are made, negative results kept, inference marked.
- **The launcher owns starting the game.** Auto-start only via opt-in `HH_AUTOSTART=1`.
- **No black bars, ever**, in any aspect mode, including "Original".
- **High frame rate by interpolation, never by changing game logic rate.**
- **F1 debug menu and HUD inspector in every build**, never gated behind an env var.
- **Windows and Linux** both built and shipped.
- The frontend and dev tooling are copied from Wave Race literally; game-specific machinery
  is written fresh from this game's measurements.
- Commit directly to `main`; push only to `danielgomesvieira2000/*`.
- Build RelWithDebInfo; never Debug (audio timing), never GCC.
- One verified change at a time; new enhancements behind a switch, off until signed off.
- Every claim in `docs/` is re-derivable from a tool in `tools/` or a named switch.

## Verified checkpoints

A build Daniel confirms is a checkpoint: record it before the next experiment.

| Date | Commit | Submodule pins | What Daniel confirmed |
|---|---|---|---|
| | | | |
