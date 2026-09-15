# Phase 05 findings — graphics, audio and saves correctness

The working record, wrong turns included; not rewritten later.

**Gate:** not met. It needs Daniel: title → New Game → opening cutscene → first battle → save to
the Controller Pak → quit → relaunch → load → resume, with correct visuals and audio pitch against
ares, and rumble in battle.

## Rumble Pak on the Controller Pak's slot (D6)

### What the game does

`func_80027D04` is libultra 2.0I's `osMotorInit`, read from the disassembly (`asm/resident.s`):
1. `__osPfsSelectBank(0xFE)` (`func_80032D40`), then `__osContRamRead(block 0x400)` (`func_80034060`);
   if byte 31 reads back `0xFE`, return `PFS_ERR_DEVICE` (the device is a Controller Pak).
2. `__osPfsSelectBank(0x80)`, read block 0x400 again; anything but `0x80` is `PFS_ERR_DEVICE`.

`__osMakeMotorData` (around `0x80027C30`) packs block `0x600` (address `0xC000`) with 32 bytes of 1 or
0\. The pak write goes through `func_80033E10` (`__osContRamWrite`).

### Run 1 (phase-04 build, `HH_PAKTRACE=1`): no rumble

The identify register was a plain echo (Rayman 2's layer). The log shows `write block=0x400
FEFEFEFE` then `read FEFEFEFE` on ports 0 and 1: `osMotorInit` concluded "Controller Pak" every
time, and no block `0x600` write ever appeared.

Beetle Adventure Racing's one-slot design (a plain echo plus a motor register) is not enough for
this game's `osMotorInit`. BAR's own comment says its identify writes `0x80` and reads `0x80` back,
a different sequence.

### First change (superseded)

In `src/si_pak.cpp`, a read of block `0x400` after a `0xFE` bank select returned zeroes; every
other value still echoed. Writes to block `0x600` call `hh::set_pak_rumble(port, data[0] != 0)`.
Both apply only on a port with a pak present. `HH_NO_RUMBLE_PAK=1` restores Rayman 2's plain echo.
In the run-1 trace, every `0x400` write other than the `0xFE` probes is `00000000`.

### Run 2 (first change, `tools/scripts/stick-check.txt`, `HH_PAKTRACE=1`)

| What | Result |
|---|---|
| motor probe on port 0 | `write FEFEFEFE` → `read 00000000`; `write 80808080` → `read 80808080`: accepted |
| port 1 (no pak) | still echoes `FEFEFEFE` (not a rumble device) |
| motor | 27 writes to block `0x600` by t≈120 s, every one `00` (motor stop after init). No start yet: nothing so far is meant to shake |
| Controller Pak | the same reads and writes as before: status, the block-0 write test, the ID, inode, inode backup and note blocks. 252 data-block operations |
| prompts | Controller Pak prompt, Rumble Pak prompt and cinematic advance at the same script times |

Most probing happens before the title (the game polls the slot during the logos). The game still
reached exploration, and the stick moved the hero (phase-04 run 7 used this build).

**What run 2 also showed:** three new writes, `84848484` to block `0x400`, each read back as
`84848484`. They come from `func_80031FF0`, which has the shape of libultra's `osGbpakInit`, the
Transfer Pak init: write `0xFE` to `0x400` and require it not to read back, then write `0x84` and
require `0x84`, then a status query and a timer. With the first change the slot passed that probe
too, so the game was told a Transfer Pak was present. Before the change, `0xFE` echoed, so the
probe failed at its first step.

### Second change: the identify register reads as a Rumble Pak's

A Rumble Pak answers `0x80` to reads of its identify range (*inferred* from memory of mupen64plus's
Rumble Pak model; the source was not re-read here). The probes above only need that `0xFE` and `0x84`
do not read back and `0x80` does.
`src/si_pak.cpp` now answers `0x80` whenever the last byte written to block `0x400` is `≥ 0x80`, and
echoes smaller values (the Controller Pak's bank numbers):

| Probe | Writes | Reads | Result |
|---|---|---|---|
| `osMotorInit` | `0xFE`, then `0x80` | `0x80`, `0x80` | Rumble Pak |
| `osGbpakInit` | `0xFE`, then `0x84` | `0x80`, `0x80` | not a Transfer Pak (`0x84` does not read back) |
| Controller Pak bank select | `0x00` | `0x00` | unchanged |

### Run 3 (second change, `tools/scripts/newgame.txt`, 130 s, `HH_PAKTRACE=1`)

| What | Result |
|---|---|
| probes | `FEFEFEFE` → `80808080`, `80808080` → `80808080`, `84848484` → `80808080` |
| motor | block `0x600` writes, all stop, after each accepted `osMotorInit` |
| Controller Pak | 315 data-block operations; prompts at the same script times |
| screen at 127 s | the press-conference cinematic, as in earlier runs |

### Run 4 (second change, `tools/scripts/stick-check.txt`, 556 s)

No lookup miss; the 19 code-file loads as before (file 24's heap copy reported). Exploration by
495 s, and the stick moves the hero in every direction (frames 498–552 s). No motor start.

**Open:** `rumble port=0 on` in a scene that shakes (battle), and whether the Rumble Pak prompt text
changes now that one is detected.

## Saves

**Wrong at first:** from the phase-04 trace (a blank pak, 130 s) I concluded the game creates no
note in a new game. Run 2's inode table was different: allocated chains, not the all-free `0x0003`.
The pak file (`%LOCALAPPDATA%\hybrid-heaven-recomp\controller_pak_1.pak`) now holds one note, created
during one of the untraced phase-04 runs:

| Field | Value |
|---|---|
| game code / publisher | `NHVE` / `0x4134` ("A4", Konami) |
| start page | 5 |
| name | `21 32 1B 2B 22 1D 0F 21 1E 1A 2F 1E 27` = "HYBRID HEAVEN" in the N64 pak character set |
| size | the inode chain runs 5 → 6 → … through the whole table (*inferred:* the note takes most of the pak) |

Every later session, including a traced one, rewrites the inode table and its backup (`0x08–0x17`)
and runs the block-0 write test at each pak check. Those checks happen at boot, GAME START and each
prompt. Where the note is created is traced next, from a blank pak.

## Audio pitch

No reference emulator is installed on this machine (no ares, simple64, Project64 or RetroArch).
The port's side: the game asks for 44,100 Hz (`osAiSetFrequency`, host log "resampling 44100 ->
48000 Hz"). The comparison against ares waits for an ares install or Daniel's ears.
