# Porting reference

How this port is put together and why each piece is the way it is: the pipeline from a
dump to an executable, the runtime harness, patches, and the enhancements. Facts about the
game are in [GAME-INTERNALS.md](GAME-INTERNALS.md). How each fact was found is in
[findings/](findings). The plan and its gates are in [PLAN.md](PLAN.md).

Each section states the **symptom first**, because a symptom is what you will have when
you come looking.

**Status:** phase 04 done: boots through logos, title, menus, pak prompts and the opening cinematic into exploration, controllable with the stick; no lookup miss in 15 minutes. Phase 05 (correctness) measured up to Daniel's checks. Phase 06: the launcher, settings, 1-2 players and F1 build and run; Daniel's checks pending. Sections below are filled as phases land.

Pinned upstream revisions ([PLAN.md](PLAN.md) D5). RT64 and RecompFrontend, including every
nested submodule, are identical to Wave Race 64: Recompiled 1.0.2's pins (compared with
`git submodule status --recursive`).

| Submodule | Commit |
|---|---|
| N64ModernRuntime (`danielgomesvieira2000/N64ModernRuntime`, branch `controller-pak`) | `b0b2b6e` = upstream `cdf5abb` (Wave Race's pin) + Controller Pak, Rayman 2 and Beetle runtime fixes |
| N64Recomp (inside N64ModernRuntime) | `81213c1` (same as Wave Race) |
| RT64 | `5473732` |
| RecompFrontend | `b1a1477` |

**Symptom: RT64 at `4337374` after `git submodule add` + `update --init --recursive`.**
The recursive update checks out the commit recorded for a *freshly added* submodule, which is
remote HEAD, not the commit checked out by hand before staging (playbook 01's pin trap, hit
again here). Re-checkout `5473732`, update its nested submodules, `git add lib/RT64`, and
verify with `git submodule status`.

## Contents

1. [The pipeline](#the-pipeline)
2. [The ELF](#the-elf)
3. [Recompiling](#recompiling)
4. [The harness](#the-harness)
5. [The frontend](#the-frontend)
6. [Patches](#patches)
7. [Widescreen](#widescreen)
8. [Frame interpolation](#frame-interpolation)
9. [Submodule patches](#submodule-patches)
10. [Testing and diagnostics](#testing-and-diagnostics)

## The pipeline

Planned (phase 01–02):

```
rom.z64 ──unpack_rom.py──▶ expanded image (ROM + 91 decompressed code files at synthetic offsets)
        ──splat (WSL)──▶ asm/ ──as/ld──▶ hybrid-heaven.us.elf ──N64Recomp──▶ RecompiledFuncs/
rom.z64 ──RSPRecomp──▶ aspMain                                     ──CMake──▶ hybrid-heaven-recomp
patches/ ──────────────────────────────────────────────────────────────────▶ RecompiledPatches/
```

Why an expanded image: 94% of the code is LZKN64-compressed in the file table
([GAME-INTERNALS.md](GAME-INTERNALS.md#the-file-table-nisitenma-ichigo)). splat and
N64Recomp need the bytes, and librecomp's `load_overlays(rom, ram, size)` needs a ROM
address per overlay section. A stable synthetic offset per file id gives both. The image
is derived from the dump and git-ignored.

## The ELF

Pipeline: `tools/unpack_rom.py` → `tools/gen_splat_yaml.py` → `tools/wsl_split.sh` (splat 0.32.2,
spimdisasm 1.42.4 in `~/hhvenv`, `tools/wsl_setup_splat.sh`) → `tools/wsl_build_elf.sh` →
`tools/verify_elf.py`. Output `elf/hybrid-heaven.us.elf` (git-ignored).

**Symptom: splat says `sha1 mismatch`.** The `sha1:` in the config is the *expanded image's*
(`99ba14e6…`), not the cartridge's. A mismatch means `unpack_rom.py` or the dump changed.

**Symptom: tens of thousands of FUNC symbols, so N64Recomp would translate data.** splat's default label
macro for data and jump tables is `glabel`, which `recomp/macro.inc` types `@function`. The config sets
`asm_data_macro: dlabel` / `asm_jtbl_label_macro: jlabel` (object-typed). Labels spimdisasm writes inside
text files still use `glabel`; `wsl_build_elf.sh` rewrites `glabel D_` to `dlabel D_` before assembling.

**Symptom: data bytes shifted by a few bytes after each text section.** The generated linker script aligns
each section end to 16. Text boundaries are therefore rounded up to 16, which is legal only because those
bytes are zero (checked by `unpack_rom.py`).

**Duplicate addresses.** 28 files define code at `0x801E1BE0`. Names are `$VRAM_$ROM`
(`func_801E1BE0_12BEDA0`): the ROM suffix is the synthetic offset and so names the file
(`include/hh/file_table.h`). All overlays share `exclusive_ram_id: overlay`, so a reference into another
window is never bound to one file; it stays undefined (`gen_link_syms.py` assigns the address).

**Naming library functions** changes what N64Recomp emits. The rules, and why the Controller Pak chain is
left unnamed, are at the top of `recomp/symbol_addrs.txt`. Tools: `match_donor_syms.py` (bodies vs other
ports' ELFs, names only), `callgraph.py` (callers, callees, registers), `jal_audit.py` (every call target
classified; must report 0 mid-function and 0 nowhere).

## Recompiling

`wsl -d Ubuntu -e bash tools/regenerate.sh` runs the whole chain; `tools/recompile.sh` is the N64Recomp /
RSPRecomp half (`recomp/hybrid-heaven.us.toml`, `recomp/aspMain.us.toml`, `recomp/overlays.txt`).

- **`use_lookup_for_all_function_calls = true`.** 15,251 calls land in another file's window; only the
  loaded file can say which function is meant.
- **Every code file is a relocatable section** (`overlays.txt`, generated). There are no `.rel` sections:
  files always load at their link address, so absolute addresses in the code are right as they stand.
  Jump tables are read relative to the calling function's own section, so shared addresses do not
  confuse them.
- **Counts must reconcile** (`tools/count_recompiled.py`): emitted = FUNC − names the runtime owns.

**Symptom: `Unhandled cop0 register in mfc0` / `Unhandled instruction: trunc.l.d` / `branching outside
of the function`.** Each was a libultra routine not yet described. Stub a routine only when nothing the
game still runs can reach it; otherwise give it its libultra name so the runtime owns it. The three cases
and their evidence are in `recomp/symbol_addrs.txt` and findings/phase-02.md.

**Port-supplied libultra:** names in N64Recomp's ignored set that recompiled code still calls and
librecomp does not implement: `__d_to_ull` (called by the game), `__d_to_ll`, `__f_to_ull`, `__ll_to_d`.

## The harness

From Pilotwings 64: Recompiled (itself Wave Race's): `src/main.cpp` (`run()`), `src/callbacks.cpp`
(SDL input, audio queue + resampler, RSP dispatch, window), `src/renderer.cpp` (the port's own RT64
context for frontend-less builds), `src/audiodiag.cpp`, `src/resample.cpp`, `src/testdrive.cpp`
(input scripts). Hybrid Heaven's own:

| File | What |
|---|---|
| `src/sections.cpp` | section tables; runtime-provided libultra at cartridge addresses (`RecompiledFuncs/runtime_funcs.inl`); **the `file_load` wrapper**, which announces each code file (by overlay id, evicting overlapping ones) before the game decompresses it; the failed-lookup report |
| `src/libultra_stubs.cpp` | `__d_to_ll`, `__d_to_ull`, `__f_to_ull`, `__ll_to_d` |
| `src/si_pak.cpp`, `src/controller_pak.cpp` | Controller Pak at the joybus + 32 KiB store in `controller_pak_1.pak` (Rayman 2), plus a Rumble Pak on the same slot (D6): identify register reads `0x80` after a bank `>= 0x80`, motor writes at block `0x600` → `hh::set_pak_rumble` |
| `src/spin_yield.cpp` | `hh_yield_in_spin`, called from TOML hooks in busy-waits (Rayman 2) |
| `src/thread_sampler.cpp` | `HH_SAMPLE=1` (Rayman 2) |

**Symptom: every game thread parked in `osRecvMesg` right after the first file loads.** A libultra
routine that posts to a runtime-owned manager is still the game's copy. Here it was `osEPiStartDma`
(the file loader's ROM reads); Rayman 2 had `osPiStartDma`. Name it so the runtime owns it.

**Symptom: `ACCESS_VIOLATION` in `queue_samples` at `rdram + 0x20000002`.** `osAiSetNextBuffer`
received a negative byte count: the audio manager's unsigned clamp (`[[patches.instruction]]` at
`0x8001FD8C`). `HH_TRACE_AI=1` prints the first 12 buffers.

**Symptom: 30 lists/s falls to 14, then screen updates stop about 30 s in, while audio continues.**
The main loop's frame limiter busy-waits on `osGetTime`; `[[patches.hook]]` at `0x80001A88` yields.
Found with `HH_FRAME_STATS` (the rate) and `HH_SAMPLE` (the main thread executing around `osGetTime`).
`tools/find_spin_loops.py` does not report it: it only considers call-free loops.

**Symptom: `microcode DMA from RDRAM 0x00F00000... runs past the 8 MB` on every audio task.** The
private command-list copy must sit below 8 MB on the runtime fork (it bounds RSP DMAs). It is at
`0x807F0000`.

**Symptom: no rumble; the trace shows `write block=0x400 FEFEFEFE` then `read FEFEFEFE`.** A plain
echo in the accessory identify register makes libultra's `osMotorInit` decide the device is a
Controller Pak. Beetle Adventure Racing's one-slot echo is not enough for 2.0I. Answer `0x80` after
any bank `>= 0x80`, as a Rumble Pak does. Answering `0x00` after `0xFE` alone also passes the motor probe,
but it lets `osGbpakInit`'s `0x84` probe read back, so the slot also reports a Transfer Pak
(findings/phase-05.md).

**Symptom: with a save on the pak, a new game says "Rumble Pak is connected to 1P controller", then
"Start game without being able to save?".** The game's slot classifier (`func_80002BE0`) lets a
successful `osMotorInit` override the Controller Pak. Serving both on one slot needs the game patch
at `0x80002C58` (`recomp/hybrid-heaven.us.toml`); the motor is still enabled by the game's own
`func_80002A94`. A/B switch: `HH_NO_RUMBLE_PAK=1`.

**Direct calls stay lookups.** With `use_lookup_for_all_function_calls`, even calls to runtime-owned
libultra are `LOOKUP_FUNC(address)`, so a function registered at a cartridge address after the
runtime table (`HH_TRACE_AI`'s wrapper) intercepts every game call to it.

## The frontend

RecompFrontend's launcher, settings, remapping and mods tab, wired as Wave Race 64 does it
(`src/frontend.cpp`; what came from where is in findings/phase-06.md). `-DHH_WITH_FRONTEND=ON`.

| Piece | Where |
|---|---|
| launcher: Start Game / Load ROM, Controls, Settings, Mods, Quit; emblem `assets/icons/Logo.svg` (`tools/make_logo.py`) | `build_launcher` |
| program id `hybrid-heaven-recomp` = the settings folder `main.cpp` registers | `init` |
| players 1–2, pads auto-assigned in connection order, keyboard always player 1 | `set_player_count_range(1, 2)`, `refresh_players` in `src/callbacks.cpp` |
| rumble: the General tab's slider gates recompinput's whole rumble path; the game's Rumble Pak writes reach it via `hh::set_pak_rumble` | `general.has_rumble_strength`, `update_rumble()` per frame |
| Main Volume and Mute When Not In Focus, applied by the port | Sound tab callbacks |
| F1: RT64 developer UI forced on, "Hybrid Heaven HUD" panel (no classifier until phase 07) | `create_render_context`, `src/inspector.cpp` |
| texture-pack mods (`rt64.json` inside a `.nrm`) | `src/mods.cpp` |
| log to `hh.log` when started without a terminal | `main` |

**Symptom: `ui_api_events.cpp: '../../../../../patches/ui_funcs.h' file not found`.** recompui
includes a header from the port by a fixed relative path. The port carries `patches/ui_funcs.h`,
which includes `recompui/event_structs.h`.

**Symptom: the launcher's art covers its own title and menu.** The SVG is laid out at full width and
centred vertically behind both. Keep the art out of the centre column and the top third.

**First run and test runs.** First run opens fullscreen at the display's size, except when
`HH_INPUT_SCRIPT` is set. A test run in a clean settings folder creates `graphics.json`,
`controls.json`, `general.json` and `sound.json`: delete them afterwards, or the next real launch
is no longer a first run.

| Variable | Effect |
|---|---|
| `HH_AUTOSTART=1` | start the stored dump without the launcher (for scripting the shipped configuration) |
| `HH_PRESENT_MODE=console\|skip\|early` | RT64 presentation mode (default early) |
| `HH_INSPECTOR=0` | no HUD panel in the F1 menu |
| `HH_TEST_INSPECTOR=<s>` | press F1 after that many seconds |
| `HH_TEST_OPEN_SETTINGS=<tab>@<s>` | open the settings menu on a tab |

## Patches

## Widescreen

Mechanism (D11): the frontend's render context passes every display list through
`src/dlcensus.cpp` before RT64 sees it. That is Wave Race's place for a rewriter, with F3DEX2 decoding
and this game's measurements.

**Symptom: pillarboxed at 16:9 with aspect Expand, and thin black borders even at 4:3.** Every view
draws inside an overscan scissor: 16,8..304,232 at 320×240, 32,16..608,464 at 640×480. The 3D
viewport is already full frame. The port rewrites exactly those scissors to the full frame, and RT64
then widens the picture to the window (findings/phase-07.md). This is on by default since Daniel asked
for widescreen in the build; `HH_FULL_FRAME=0` turns it off for an A/B. The hi-res letterbox
(32,90..608,390) is left alone.

**F3DEX2 is not Fast3D.** `G_MOVEWORD` carries its index in bits 16–23 and its offset in the low 16
bits (the game emits `0xDB060018` for segment 6). A texture rectangle is followed by `G_RDPHALF_1`
(0xE1) and `G_RDPHALF_2` (0xF1). `G_MTX` stores its parameters XOR `G_MTX_PUSH`. Nothing exists
between 0x07 and 0xD3, so a walker that reaches such a byte has left the list.

| Variable | Effect |
|---|---|
| `HH_FULL_FRAME=0` | keep the game's overscan scissors (pillarboxed at 16:9); full frame is the default |
| `HH_DL_CENSUS=<n>` | every n-th list: colour images, viewports, scissors, projections, triangles, rectangles (read-only) |
| `HH_WINDOW_SIZE=WxH` | windowed test run at that size |
| `HH_NO_HUD_REWRITE=1` | never submit the rewritten copy (classes still listed in F1) |
| `HH_HUD_REWRITE_TRACE=1` | each identity the rewriter meets, once, with its class and whether it was a call, a branch or a rectangle |
| `HH_TEST_HUD_OVERRIDE=<identity>=<class>@<s>` | set a class as the panel's dropdown would, after that many seconds |

**The HUD, live.** `src/dlcensus.cpp` publishes every frame's 2D elements to the F1 "Hybrid Heaven
HUD" panel: `tex:<image>`, `fill:<colour>`, and `dl:<list>` for orthographic triangles. While any
element has a class (dropdown, or `hud.json` in the settings folder, loaded at startup),
`src/hudrewrite.cpp` copies the frame's lists to `0x807A0000` / `0x807C8000` and inserts RT64's
extended GBI around the classified draws. The change shows on the next frame.

**Promoting tags.** `python tools/promote_hud_tags.py --clear` merges the local `hud.json` into
`load_defaults()` in `src/inspector.cpp` (between markers; additive, idempotent) and empties the
file. Rebuild, then commit. Precedence, highest first: the panel's dropdown, `hud.json`, the built-in
table.

**Symptom: tags made in one scene break another (the Expansion Pak screen smears at the left).**
An address or colour is not an identity here. Segment 3 is remapped per scene, the heap reuses
texture addresses, and `fill:<colour>` names every rectangle of that colour; the first promoted
`fill:0x00000000` pinned a black clear to the right edge. Identities carry content
(`include/hh/hudid.h`): `tex:<addr>#<image hash>`, `dl:<addr>#<list hash>`, `fill:<colour>@<rect>`.
Full-frame clears are never classifiable. `HH_HUD_ELEMENTS_LOG=1` logs each identity once with its
extent. Before promoting, A/B scenes other than the one tagged against `HH_NO_HUD_REWRITE=1`.

**Symptom: part of a HUD widget moves and part stays.** One of its lists is reached by a `G_DL`
branch rather than a call (the radar dial, `dl:0x80181860`). A branch never returns, so the class is
applied from the branch to the inlined list's end command.

## Frame interpolation

## Submodule patches

Every change to a submodule is an idempotent script in `tools/`, run by
`python tools/patch_all.py`. Rerun it after any submodule update.

| Script | Submodule | What and why |
|---|---|---|
| `patch_rsprecomp.py` | N64Recomp (RSPRecomp) | indirect-jump dispatch masks the low two bits (the RSP ignores them); from Wave Race |
| `patch_n64recomp.py` | N64Recomp | `use_lookup_for_all_function_calls` as a config key, for calls into shared-vram overlay windows; from Wave Race |
| `patch_runtime_shutdown.py` + `patches/runtime-shutdown.patch` | N64ModernRuntime | join game and timer workers before RDRAM and queues are released (intermittent exit crash); from Wave Race/Pilotwings. **One hunk re-based onto the fork**: `ultramodern.hpp` has Beetle's `set_paused`/`is_paused` above `join_event_threads`, so the Wave Race context (`void quit();`) did not match |
| `patch_recompinput.py` | RecompFrontend | `players::auto_assign_controllers` (pads assigned in connection order, keyboard stays player 1); from Wave Race |
| `patch_rt64_eventfilter.py` | RT64 | `~ApplicationWindow` restores the previous SDL event filter (crash on every exit otherwise); from Wave Race |
| `patch_rt64_inspector.py` | RT64 | `RT64_PortInspectorHook` in the F1 developer UI; F2 unbound; from Wave Race |
| `patch_rt64_texturepacks.py` | RT64 | `RT64_SetTexturePacks` for texture-pack mods (anchors on the inspector patch); from Wave Race |
| `patch_rt64_pairing.py` | RT64 | transform-pairing counters for interpolation measurement (`RT64_GetTransformPairing`); from Pilotwings |

**Not used: Wave Race's `patch_librecomp.py`.** Its anchor (`get_function`'s
`fprintf("Failed to find function…")` as the first statement of the miss branch) is gone on
the fork, which already has the better mechanism (Rayman 2, fork commit `ddf510b`):
`recomp::overlays::set_lookup_failure_handler` plus a per-thread ring of the last 32 resolved
indirect targets (`get_lookup_history`). The port installs the handler in phase 03.

Anchors verified against these revisions on 2026-09-15: first run patched everything, a
second run reported every patch already applied.

## Testing and diagnostics

### Survey tools

| Tool | What it measures |
|---|---|
| `tools/identify_rom.py <rom>` | identity and hashes; exits non-zero on any other dump |
| `tools/survey_rom.py <rom>` | microcode strings, plain-code blocks, JAL floor (its flat-image window overruns into data for this game: see findings/phase-00) |
| `tools/nisitenma.py <rom> [--list] [--extract DIR]` | file table, LZKN64 decompression of every file, code classification, reserved regions, aspMain byte check |
| `tools/verify_elf.py` (WSL) | phase-01 gate: segment bytes, symbol placement, ABS/zero-size/overlapping FUNCs |
| `tools/jal_audit.py` (WSL) | every `jal` target: own/global function start, cross-window, mid-function, nowhere |
| `tools/match_donor_syms.py [--near] [--write]` (WSL) | library names from donor bodies |
| `tools/callgraph.py [--dis] <fn>` | callers, callees, hardware pages, cop0/cop1 registers |

### Environment variables

Prefix `HH_`.

| Variable | Effect |
|---|---|
| `HH_INPUT_SCRIPT=<file>` | timed input (`tools/scripts/*.txt`; `2:` prefix = player 2) |
| `HH_DEBUG_LOADS=1` | every code-file load: id, address, size, files evicted, and the last 6 addresses the thread resolved (the caller chain). A load away from the link address is always reported |
| `HH_FRAME_STATS=1` | display lists per 60 screen updates |
| `HH_AUDIO_STATS=1` | audio queue depth, silence inserted, peak amplitude, every 2 s |
| `HH_AUDIO_DUMP=1` | WAV of exactly what is handed to SDL |
| `HH_AUDIO_HEADROOM_MS`, `HH_AUDIO_PERIOD`, `HH_AUDIO_NO_RESAMPLE` | audio output knobs |
| `HH_TRACE_AI=1` | the first 12 `osAiSetNextBuffer` calls |
| `HH_PAKTRACE=1` | every Controller Pak status/read/write on the joybus, and each motor on/off |
| `HH_NO_RUMBLE_PAK=1` | the slot is a Controller Pak only (Rayman 2's plain identify echo; `osMotorInit` fails) |
| `HH_SAMPLE=1` | thread sampler report every 2 s (perturbs timing; locate with it, do not measure behaviour) |
| `HH_YIELD_MS=<0-100>` | spin-yield wait, default 1 |
| `HH_SKIP_DL=1` | do not hand display lists to RT64 (bisect renderer faults) |
| `HH_EXPANSION_PAK=0` | `osGetMemSize` (`0x8002C0B0`) reports 4 MB instead of the runtime's 8 MB (test switch; the game then skips its "Expansion Pak Enhanced" screen) |

Set variables in the calling shell: `tools/boot_runs.ps1 -Env "A=1","B=1"` passes only the first.

### Traps

- Symbolise a crash or sample offset: `llvm-symbolizer --obj=build\hybrid-heaven-recomp.exe --relative-address --demangle <offset>`.
- `tools/boot_runs.ps1` (gate runs) and `tools/shoot_run.ps1` (window grabs every N seconds) kill the
  process at the end; the window must be visible for grabs. They photograph the desktop: a covering
  terminal is silently what gets saved (phase 04, run 6). When a picture matters, use
  `python tools/capture_frames.py OUTDIR FROM TO --exe build\hybrid-heaven-recomp.exe --title "Hybrid Heaven: Recompiled" --rom rom.z64 --env HH_INPUT_SCRIPT=<file>`,
  which reads the window through Windows Graphics Capture. Run long captures from Bash: a
  background PowerShell task closes the child's console (`SDL_QUIT` ~8 min in).
- **Test in a sandbox:** `python tools/test_sandbox.py --exe build/hybrid-heaven-recomp.exe --rom rom.z64
  [--capture FROM TO --title "Hybrid Heaven: Recompiled"] [--seconds N] --out <dir> [--env K=V] [--seed <file>]`
  copies the exe, DLLs and assets to a temp folder with `portable.txt`, runs, keeps the files the run
  wrote in `<dir>/settings/`, and deletes the folder. The build directory and the player's settings
  are never written. A `portable.txt` left in `build/` once redirected Daniel's own session there.

---

## Keeping this current

This file describes the *port*: the toolchain, the runtime, the renderer, and the
techniques used against them. When a later change fixes something in one of those -- or
finds that something written here is no longer true of a newer submodule -- update this
file in the same commit that makes the change, and say what the symptom was. A finding
without its symptom is much harder to find again.

Facts about Hybrid Heaven itself belong in [GAME-INTERNALS.md](GAME-INTERNALS.md).
