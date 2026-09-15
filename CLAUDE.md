# Working in this repository

Hybrid Heaven: Recompiled — a static-recompilation PC port of Hybrid Heaven (USA)
(game code `NHVE`, SHA-1 `16dbc21620b52deab5c5abf8a309ac60adfbee85`). Read the docs map below before
changing anything you have not touched before.

## Docs map

| File | What it holds |
|---|---|
| `docs/PLAN.md` | phases, gates, standing constraints |
| `docs/findings/phase-NN.md` | the working record per phase, wrong turns included; not rewritten |
| `docs/PORTING.md` | port facts: toolchain, runtime, renderer, patches (symptom first) |
| `docs/GAME-INTERNALS.md` | game facts: addresses, tables, formats, drawing conventions |
| `docs/BUILDING.md` | step-by-step build |
| `docs/issues/NNN-*.md` | one file per visual/behaviour bug, from `docs/issues/TEMPLATE.md` |
| `docs/releases/X.Y.Z.md` | short release notes; `CHANGELOG.md` indexes them |

**Update the affected reference doc in the same change that makes it wrong** —
game facts in GAME-INTERNALS.md, port facts in PORTING.md. Record the measurement
and the switch that re-derives it; keep negative results; mark inference as inference.

## Hard rules

- **Never commit game data.** No ROM, ELF, extracted or derived asset. Do not work
  around `.gitignore`.
- **Never edit `RecompiledFuncs/` or `RecompiledPatches/`.** They are generated.
  Changes go in `recomp/*.toml`, `patches/`, or a script in `tools/`.
- **Never hand-edit a submodule** (`lib/`). Every change is an idempotent
  `tools/patch_*.py`, run by `python tools/patch_all.py`.
- **Never change the decompilation** (`reference/`: the Goemon and Castlevania decomps, cloned for names only; they publish no license, so nothing from them is copied into the tree).
- **One revision only**: every address is tied to SHA-1 `16dbc21620b52deab5c5abf8a309ac60adfbee85`.

## Game facts that shape everything

- No decompilation exists; symbols come from splat run from scratch.
- 94% of the code is LZKN64-compressed in the Nisitenma-Ichigo file table (`tools/nisitenma.py`);
  92 code files load at fixed, often shared, addresses through `func_8000469C`.
- The screen is drawn inside an overscan scissor; the port draws it full frame for widescreen, and
  anchors HUD elements by rewriting display lists (`src/dlcensus.cpp`, `src/hudrewrite.cpp`).
  HUD identities must carry content (`include/hh/hudid.h`): addresses are reused across scenes.
- Controller Pak saves + Rumble Pak, 2 players, optional Expansion Pak (reads `osMemSize`).

## Build

| Directory | What |
|---|---|
| `build/` | Windows, clang-cl + Ninja, RelWithDebInfo (Debug breaks audio timing), runtime + recompiled + frontend ON |
| `build-linux/` | Linux / WSL (`tools/build_linux.sh`) |
| `lib/N64ModernRuntime/N64Recomp/build-linux/` | N64Recomp + RSPRecomp, built under WSL (`tools/wsl_build_recompiler.sh`) |

Regenerate after a submodule or config change: `python tools/patch_all.py`, then
`wsl -d Ubuntu -e bash tools/recompile.sh` (a toml change) or `tools/regenerate.sh` (the whole
dump → ELF → C chain, after `python tools/unpack_rom.py rom.z64`), then rebuild. Packaging and
releases: `docs/BUILDING.md` §8–9.

Test runs: use `python tools/test_sandbox.py` (a throwaway copy of the build with its own settings,
deleted afterwards; `--capture FROM TO` records frames). Never leave a `portable.txt` in `build/`.

## Environment variables

All port switches use the prefix **`HH_`** (e.g. `HH_INPUT_SCRIPT`,
`HH_AUTOSTART`). A change that could regress on someone else's machine
gets a `HH_NO_...` switch. List them in PORTING.md.

## How to work

- **Land one verified change at a time.** When several mechanisms affect the same
  pixels, change one and confirm it before the next.
- **Verify by running the game**, with scripted input and `tools/capture_frames.py`,
  not only by reading code or grabbing one frame.
- **Timebox investigations.** If a few measurements do not converge, write down
  what was measured and check in.
