# Porting reference

How this port is put together and why each piece is the way it is: the pipeline from a
dump to an executable, the runtime harness, patches, and the enhancements. Facts about the
game are in [GAME-INTERNALS.md](GAME-INTERNALS.md). How each fact was found is in
[findings/](findings). The plan and its gates are in [PLAN.md](PLAN.md).

Each section states the **symptom first**, because a symptom is what you will have when
you come looking.

**Status:** phase 00. Only the survey exists; sections below are filled as phases land.

Pinned upstream revisions (planned, [PLAN.md](PLAN.md) D5; verified in phase 00):

| Submodule | Commit |
|---|---|
| N64ModernRuntime (`danielgomesvieira2000/N64ModernRuntime`, branch `controller-pak`) | `b0b2b6e` (planned) |
| N64Recomp (inside N64ModernRuntime) | as the runtime pins it |
| RT64 | `5473732` (planned) |
| RecompFrontend | `b1a1477` (planned) |

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
| | | |

## Testing and diagnostics

### Survey tools

| Tool | What it measures |
|---|---|
| `tools/identify_rom.py <rom>` | identity and hashes; exits non-zero on any other dump |
| `tools/survey_rom.py <rom>` | microcode strings, plain-code blocks, JAL floor (its flat-image window overruns into data for this game: see findings/phase-00) |
| `tools/nisitenma.py <rom> [--list] [--extract DIR]` | file table, LZKN64 decompression of every file, code classification, reserved regions, aspMain byte check |

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
