# Phase 06 findings — frontend

The working record, wrong turns included; not rewritten later.

**Gate:** not met; it is Daniel's (docs/PLAN.md phase 06). He should pick his dump in the launcher,
play with a pad, then with the keyboard and no pad attached, see settings survive a restart from
another working directory, and open F1. What could be checked without him is below.

## What was copied, and from where

| Piece | Source | Changed |
|---|---|---|
| `src/frontend.cpp`, `include/hh/frontend.h` | Wave Race 64 (structure, launcher, tabs, test hooks, forced developer mode) + Pilotwings 64 (bindings written on first run and on exit) + Rayman 2 (`HH_AUTOSTART`) | identity; no water, music, draw-distance or field-of-view options; no display-list rewriter; rumble text; first-run fullscreen skipped while `HH_INPUT_SCRIPT` is set (BAR's rule) |
| `src/inspector.cpp`, `include/hh/inspector.h` | Wave Race 64 | water sun editor removed; panel says when no classifier feeds it |
| `src/mods.cpp`, `include/hh/mods.h` | Wave Race 64 (texture packs as mods) | identity; a comment's manifest name corrected to `mod.json` |
| `src/main.cpp` frontend path, `hh.log` redirect | Wave Race 64 | identity |
| `src/callbacks.cpp`: `refresh_players`, two-player `get_input`, player 2's device info | Wave Race 64 | player 2 reports no pak; the motor stops while muted and unfocused |
| `patches/ui_funcs.h` | Wave Race 64 | include guard |
| `assets/recomp.rcss`, `assets/icons/*` (except `Logo.svg`), `assets/promptfont/` | Wave Race 64 | none |
| `assets/icons/Logo.svg`, `assets/AppIcon.ico`, `src/app.rc` | new: `tools/make_logo.py` | original emblem (faceted crystal with a twin helix), nothing from the cartridge |

The RecompFrontend patches (`patch_recompinput.py` for `auto_assign_controllers`,
`patch_rt64_inspector.py`, `patch_rt64_texturepacks.py`) were already applied in phase 00. The pad's
menu toggle is RecompFrontend's default, Back/View; Start stays the game's.

## Build

`cmake -B build -DHH_WITH_FRONTEND=ON` on the existing tree, then build.
- **First failure:** `ui_api_events.cpp: fatal error: '../../../../../patches/ui_funcs.h' file not found`.
  recompui includes a port header by a fixed relative path; every port carries `patches/ui_funcs.h`.
  Fixed by adding it.
- After that: 81 steps, no errors.

## Runs (Windows, Iris Xe, 960×720 window)

Frames recorded with `tools/capture_frames.py`. A comments-only `HH_INPUT_SCRIPT` kept test windows
out of first-run fullscreen.

| Run | Switches | Result |
|---|---|---|
| launcher, no arguments | `HH_TEST_OPEN_SETTINGS=general@9` | Launcher: title "Hybrid Heaven: Recompiled", **Start Game** (the dump accepted in phase 03 is stored), Controls, Settings, Mods, Quit; `v0.0.1` in the corner. Settings tabs General, Graphics, Sound, Controls, Mods. Log: `player 1 profiles: controller 1, keyboard 0`, `0 controllers connected; assigned to 1 player`, `mod content type registered: rt64.json` |
| launcher, emblem v2 | — | title and menu legible; two emblems flank them |
| autostart | `HH_AUTOSTART=1 HH_TEST_INSPECTOR=16` | `HH_AUTOSTART: starting the game without the launcher` about 1 s in; Konami logo at 2 s, KCEO logo, the Expansion Pak screen. F1 at 16 s opens RT64's menu with the **"Hybrid Heaven HUD"** panel (state 0x00, frame 0, 0 elements, "No classifier is feeding this panel yet") and RT64's own windows |
| scripted, dump on the command line | `newgame-prompts.txt`, `HH_PAKTRACE=1` | title → menu → GAME START → the cinematic; pak unchanged; 24 motor-stop writes. Scripted input reaches the game through the frontend's `get_input` branch |

**Wrong turn: the first emblem.** A single emblem centred in a 680×360 viewBox sat behind the title
and the menu text. The launcher lays the SVG out at full width and centres it vertically. The
second version draws two emblems at 55% scale, 100 units in from each edge. At 4:3 the title
(about 28% down) and the menu column (37–63% across) are clear.

**Not explained: menu activity no hook caused.** In the autostart run the settings menu opened at
3.2 s, switched to Graphics, moved through its options, and HUD Placement changed from 16:9 to
Expand (saved in `graphics.json` at 12:21:21). The window was also resized. In the first launcher
run the menu opened on Sound, not General, and that window grew too. No test hook does any of this
(`game.log` has only `test: pressed F1`). *Inferred:* someone was using the mouse or keyboard at the
machine during these runs. No synthetic keystrokes were used afterwards, because they would go to
whichever window had focus.

**Settings restored:** the runs created `controls.json`, `general.json`, `graphics.json`,
`sound.json` and their `.bak` copies in `%LOCALAPPDATA%\hybrid-heaven-recomp`. They were deleted
afterwards, so Daniel's first launch is a real first run (fullscreen at the display's size).
`controller_pak_1.pak` is byte-identical to its backup.

## Not checked here

- A real pad: none is attached to this machine (`0 controllers connected`).
- The keyboard, typed: it would need synthetic input (above).
- Load ROM with a fresh settings folder (the stored dump was used).
- Linux (phase 09).
