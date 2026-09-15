# Porting reference

How this port is put together and why each piece is the way it is: the pipeline from a
dump to an executable, the runtime harness, patches, and the enhancements. Facts about the
game are in [GAME-INTERNALS.md](GAME-INTERNALS.md). How each fact was found is in
[findings/](findings). The plan and its gates are in [PLAN.md](PLAN.md).

Each section states the **symptom first**, because a symptom is what you will have when
you come looking.

**Status:** phase 01 done (byte-identical ELF, 15,947 functions, 147 library names). Sections below are filled as phases land.

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
5. [Patches](#patches)
6. [Widescreen](#widescreen)
7. [Frame interpolation](#frame-interpolation)
8. [Submodule patches](#submodule-patches)
9. [Testing and diagnostics](#testing-and-diagnostics)

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

## The harness

## Patches

## Widescreen

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
| | |

### Traps

---

## Keeping this current

This file describes the *port*: the toolchain, the runtime, the renderer, and the
techniques used against them. When a later change fixes something in one of those -- or
finds that something written here is no longer true of a newer submodule -- update this
file in the same commit that makes the change, and say what the symptom was. A finding
without its symptom is much harder to find again.

Facts about Hybrid Heaven itself belong in [GAME-INTERNALS.md](GAME-INTERNALS.md).
