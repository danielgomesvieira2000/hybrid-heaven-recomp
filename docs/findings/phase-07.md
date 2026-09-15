# Phase 07 findings — widescreen

The working record, wrong turns included; not rewritten later.

**Gate:** not met. Entered before phase 06's gate (Daniel's checks), with D11 decided from the
measurements below (docs/PLAN.md departures). The exit is Daniel's: every screen of the phase-05
stretch, menus and a boss fight right at 16:9, 21:9 and 4:3.

## Tools added

| Tool | What |
|---|---|
| `HH_WINDOW_SIZE=WxH` | a windowed run at that size, whatever the saved settings say (BAR's knob) |
| `HH_DL_CENSUS=<n>` (`src/dlcensus.cpp`) | every n-th top-level display list: colour images, viewports, scissors, projections (aspect, fovy, near/far), triangle counts, fill and texture rectangles. Read-only |
| `HH_FULL_FRAME=1` | overscan scissors rewritten to the full frame (below). Off by default until signed off |
| `portable.txt` in `build/` | test runs keep settings, dump copy and pak beside the exe, away from the player's folder; removed after the runs |

## Run 1: a 16:9 window changes nothing

`tools/scripts/stick-check.txt`, `HH_WINDOW_SIZE=1280x720`, frames 495–556 s. Exploration is
**pillarboxed to 4:3** in the middle of the window, with RT64's aspect ratio at Expand (the library
default). The radar sits at the top left of the 4:3 picture.

## Run 2: what the game draws (`HH_DL_CENSUS=240`, boot to title)

| Screen | Colour image / depth | Scissor | Viewport | Projection |
|---|---|---|---|---|
| KCEO logo, Expansion Pak screen | `0x00400000` / `0x00700000`: **640×480** (hi-res, Expansion Pak memory) | full frame for the clears; **32,16..608,464** for the scene | 320,240 scale (full) and 288,216 (inset) | perspective, aspect 1.3333, fovy 35°, near 5, far 1800.5 |
| title | `0x000CE9C0` / `0x0038F800`: **320×240** (the "reserved" ids 2 and 5 of the file table) | full frame for the clears; **16,8..304,232** for the scene | 160,120 (full) | perspective, aspect 1.3333, fovy 30°, near 5, far 1800.5 |

The scene scissor is 90% × 93% of the frame: an overscan inset. The earlier 4:3 window grabs
agree. The picture there measured 1190×925 px (1.286), which is 288/224, so the game shows thin
black borders **even at 4:3** (a standing-constraint violation, "no black bars").

Where it comes from: `func_80007BD0` fills a camera structure (`a0+0x2C`) with the rectangle as
four shorts plus a viewport copied from resident data. There are three branches:

| Mode (chosen by `func_80130290` / `func_801302CC`) | Rectangle | Viewport data (scale, trans) |
|---|---|---|
| hi-res | 32,16..608,464 | `D_800433B0`: 320,240 / 320,240 (full) |
| hi-res, second mode | **32,90..608,390** (a letterbox) | `D_800433C0`: 288,216 / 320,240 (inset) |
| low-res | 16,8..304,232 | `D_800433A0`: 160,120 / 160,120 (full) |

Four sibling functions do the same (`func_800080D4`, `func_800085A0`, `func_80008A0C`,
`func_80008E60`), and `func_8001AA50` has the low-res constants too. `G_SETSCISSOR` (`0xED000000`)
is packed at 11 sites in resident code, 2 in file 8 and more in overlays (24, 25, …).

**D11 follows from this:** fixing it at each emitter is a long list of instruction patches; one
pass over each submitted list sees every scissor. The 3D viewport is already full-frame in both
main modes, so only the scissor has to change.

## Change: `HH_FULL_FRAME=1`

`src/dlcensus.cpp` `snap_overscan`, called from the frontend's render context before RT64 gets the
list. It rewrites in place a `G_SETSCISSOR` whose words equal exactly 16,8..304,232 or 32,16..608,464
(mode bits kept) to 0,0..320,240 or 0,0..640,480. The letterbox rectangle is left alone.

### Run 3: the title, off and on (1280×720)

| | Off | On |
|---|---|---|
| picture | pillarboxed, inset | **fills the window**: the 3D background extends to both edges; logo and text stay centred at their own size |
| log | — | `HH_FULL_FRAME: first list with an overscan scissor: 1 snapped` |

**Wrong turn, census:** `G_MOVEWORD`'s fields were decoded Fast3D-style (offset in bits 8–23). The
census then never saw segment 3 set, and every call through it "left the list" (10 of 46 in a
title list). The game's own code emits `0xDB060018` (index 6 = segment in bits 16–23, offset
0x18 = segment 6 × 4 in the low bits), which settles the F3DEX2 layout. Fixed. The snap itself had
worked on the top-level list, which is where the title's scissor is.

### Run 4: exploration at 16:9, `HH_FULL_FRAME=1` (`stick-check.txt`, frames 495–556 s)

| What | Result |
|---|---|
| picture | **fills the 1280×720 window**: walls, floor, doors to both edges |
| 2D | the radar stays where it is in the 4:3 picture (centred box, not the window's edge); dialogue boxes centred |
| census, a cinematic list (t≈250 s) | 320×240; scissor 0,0..320,240 after the snap; viewport full; perspective aspect 1.3333, fovy 33.3°, near 5, far 2003.1; about 3,500 triangles, 118 calls, 0 walks left the list |
| census, exploration (list 13500) | 320×240, same projection shape (fovy 35°, far 1800.5); **the radar is two texture rectangles 27,19..59,51** (images `0x802866F8`, `0x80286AF8`) plus 4 triangles under a screen orthographic projection (scale 2/320, −2/240, then translate −160,−120); a second scissor 197,143..277,223 |
| edges while the camera turns (512.5–517 s, a strip 110 px wide at each side, every 10th frame) | wall and floor geometry continuous at both edges through a pan and a cut; nothing missing or popping in these samples |
| lookup misses | 0 |

*Not yet shown:* whether objects (not room geometry) are culled against the 4:3 frustum. Stills
every third of a second cannot show it. RT64's free camera (F1) settles it (playbook 08).

## Still to do in this phase

- The HUD: a classifier feeding the F1 panel, then anchoring (the radar to the left edge) with
  Daniel driving the inspector.
- The hi-res letterbox mode (32,90..608,390) and the RESOLUTION menu entry.
- 21:9 and 4:3 windows; the Expansion Pak screen's own inset viewport (288×216).
- Deciding whether `HH_FULL_FRAME` becomes the default (standing constraint: after sign-off).
