# Phase 01 findings — ROM to ELF

The working record, wrong turns included; not rewritten later. Lasting facts are copied into
[PORTING.md](../PORTING.md) and [GAME-INTERNALS.md](../GAME-INTERNALS.md).

**Gate:** met (2026-09-15).
- The ELF's 93 code segments are byte-identical to the expanded image built from the dump,
  with 0 wrong size and 0 wrong bytes.
- Every one of 40,264 address-named symbols sits at its address and in its own file.
- 15,947 FUNC symbols: 0 ABS, 0 zero-size, 0 overlapping.
- 38,591 `jal`s: 0 land mid-function or outside any code file.
- 147 library functions are named from their bodies, including the controller and Controller
  Pak paths. `osPfsIsPlug` is called by game code, so the save medium is confirmed in code.

Reproduce (Windows, then WSL):

```
python tools/unpack_rom.py rom.z64
python tools/gen_splat_yaml.py
wsl -d Ubuntu -e bash tools/wsl_setup_splat.sh          # once
wsl -d Ubuntu -e bash tools/wsl_split.sh
wsl -d Ubuntu -e bash tools/wsl_build_elf.sh
wsl -d Ubuntu -e python3 tools/verify_elf.py
wsl -d Ubuntu -e python3 tools/jal_audit.py
wsl -d Ubuntu -e python3 tools/match_donor_syms.py [--near] [--write]
python tools/callgraph.py [--dis] <name-or-0xADDR>
```

## Answer

The compressed code became an ordinary asm-only splat project by giving each decompressed file
a synthetic ROM offset in a local "expanded image". splat run from scratch (splat 0.32.2,
spimdisasm 1.42.4, Rayman 2's pins) recovered 15,947 functions, and every boundary checked out.

Overlays call each other's windows directly at **15,251** call sites. That can only be
resolved at run time, so phase 02 needs `use_lookup_for_all_function_calls` (Wave Race's
`patch_n64recomp.py`, already applied).

## Measurements

### The expanded image (`tools/unpack_rom.py`)

| What | Result |
|---|---|
| Layout | ROM `0x0–0x4E7D0` unchanged, zero to `0x1000000`, then code files in id order, each padded to 16 bytes |
| Code files | **92**: ids 8–22, 24–100. Id 23 is excluded: it sits at a KSEG0 address but has no `jr $ra`, only tables. Id 99 is included: it has one function (`lui/addiu` at +0) and data |
| Image | 20,356,048 bytes, SHA-1 `99ba14e6ba243b08daf017fdfef5622aa5fae2df` (recorded in the splat config; splat refuses a different image) |
| Runtime table | `include/hh/file_table.h` (generated, committed: id, synthetic offset, vram, size) |

### Text/data boundary per file

Rule: text ends just past the last `jr $ra` and its delay slot.

| Check | Result |
|---|---|
| Function prologues (`addiu $sp,$sp,-N`) after that point, any file | 0 |
| Bytes between the text end and the next multiple of 16 | all zero in every file, so the boundary is rounded up to 16 (see the negative result on alignment) |
| What follows | zero padding, then data (`00000000 80000000 8012E584…`, `F000FC00…`) |
| Resident CPU text end | `0x800350C0`, not the last `jr $ra` at `0x800362A0`. `rspboot` starts at `0x800350C0` (RSP cop0 `mtc0`, `jal 0x8400103C`), then the graphics microcode text (cop2 vector instructions) and `aspMain` at ROM `0x37130`. Resident text is `0x80000400–0x800350C0` (`0x34CC0` bytes) |

### splat config (`tools/gen_splat_yaml.py` → `recomp/hybrid-heaven.us.yaml`)

| Choice | Why |
|---|---|
| `exclusive_ram_id: overlay` on every file except the resident image and file 8 | Files at one address are alternatives. A shared id stops splat binding a reference to whichever file owns the address in the image; it stays undefined and becomes a run-time lookup. Global segments do not overlap any overlay range, so splat's global/overlay overlap check passes |
| `symbol_name_format: $VRAM_$ROM` | 28 files define `func_801E1BE0`. The ROM suffix makes names unique and says which file a symbol belongs to |
| `asm_data_macro: dlabel`, `asm_jtbl_label_macro: jlabel` (object-typed in `recomp/macro.inc`) | With splat's default `glabel`, 23,296 data labels and 260 jump tables were FUNC symbols (39,502 total), which N64Recomp would translate as code |
| `glabel D_` → `dlabel D_` inside text files (`wsl_build_elf.sh`) | spimdisasm writes any label inside a text file with the function macro. 3 such labels became zero-size FUNCs overlapping their function: `0x800270C0` (`__osException`, now named), `0x800279A0` (`__osCleanupThread`, now named), `0x803787A4` (a table base in file 56 computed as `base + index*2`, which lands inside code). 1 remains after naming |

### Symbols

| Stage | FUNC | ABS | zero-size | overlap |
|---|---|---|---|---|
| first link (data labels as `glabel`) | 39,481 | 0 | 27 | 14 |
| data/jtbl macros | 15,948 | 0 | 3 | 3 |
| mid-code data labels relabelled | 15,945 | 0 | 0 | 0 |
| names written (`__osException`, `__osCleanupThread` split out) | **15,947** | 0 | 0 | 0 |

`jal_audit.py` over 38,591 `jal`s:

| Target | Count |
|---|---|
| start of a function in the resident image or file 8 | 16,471 |
| start of a function in the caller's own file | 6,869 |
| inside another file's range, and a function starts there in at least one file | **15,251** |
| inside a function (boundary bug) | **0** |
| in no code file | **0** |

Example cross-window calls: file 26 (`0x801E1BE0`) calls `0x8038BEC8` (files 99/100) and
`0x801C0B8C` (files 24/25). Some targets start a function in two files (`0x8038D28C`), so only the
file loaded at run time can say which is meant.

### Library names (`tools/match_donor_syms.py`, then `tools/callgraph.py`)

| Source | Names |
|---|---|
| Body identical to a library function in Beetle Adventure Racing's `recomp.elf` (libultra 2.0I), Pilotwings 64's or Wave Race 64's ELF (jal targets, `%hi/%lo` fields masked; hardware-register `lui` kept) | 126 |
| Hand-verified from registers, callers, callees and the data a body reads (evidence beside each entry in `recomp/symbol_addrs.txt`) | 21 |

Hand-verified: `osInitialize`, `osGetMemSize`, `__osDisableInt`, `osCreatePiManager`,
`__osSpSetPc`, `osSetEventMesg`, `osViSetSpecialFeatures`, `osViSetYScale`,
`osAiSetFrequency`, `osViGetCurrentFramebuffer`, `osViGetNextFramebuffer`,
`__osViGetCurrentContext`, `osContStartReadData`, `osContGetReadData`, `osCartRomInit`,
`__osExceptionPreamble`, `__osException`, `__osDispatchThread`, `__osCleanupThread`, `entrypoint`.

Deliberately **not** named although identified (the Controller Pak and Rumble Pak plumbing):
`__osSiGetAccess 0x80027EB0`, `__osSiRelAccess 0x80027EF4`, `__osSiCreateAccessQueue 0x80027E60`,
`__osContGetInitData 0x80028090`, `__osPfsGetInitData 0x8002AA40`, `__osPackReadData 0x800284C0`,
`osPfsIsPlug 0x8002A7D0`, `__osPfsRequestData 0x8002A970`, `__osPackRequestData 0x80028160`.

N64Recomp at `81213c1` lists every one of these as either reimplemented (librecomp answers "no
pak") or ignored (no body emitted). Unnamed, the game's own Pfs code runs and reaches the port only
through `__osSiRawStartDma`, which is named and which the port serves at the joybus level (Rayman 2's
`src/si_pak.cpp`, phase 05).

## Negative results

- **Default text-end boundaries drift the data.** splat's linker script does `. = ALIGN(., 16)` after
  every text object. With text ends measured to the word (`0x217BC`), the data object would start up to
  12 bytes late: Wave Race's drift trap from playbook 02, avoided before the first link by rounding each
  boundary up to 16. That is only allowed because the bytes in between are zero in every file, which
  `unpack_rom.py` checks.
- **splat's `sha1:` is the split target's**, not the cartridge's. The first split refused
  (`sha1 mismatch … was 99ba14e6…`). Recording the image's hash turned that into a check on the unpack
  step.
- **"The resident CPU code ends at the last `jr $ra`" (`0x800362A8`)** was wrong. The last 0x11E8
  bytes before it are RSP microcode that happens to contain `jr $ra` (`0x03E00008` is also a valid RSP
  instruction). Found by disassembling around `rspboot`'s cop0 writes.
- **Masking every `lui` made register accessors identical.** `__osSpSetStatus` (3 donors) and
  `osDpSetStatus` (Wave Race) matched one 3-word body. Keeping `lui` values in `0xA000–0xBFFF`
  separated them.
- **Donor game names match short bodies.** `snowDisable`, `proxAnimDispatchEvent2`, `SysUtils_Rand`,
  `demoPositionLerp` and `__amDmaNew` matched tiny Hybrid Heaven functions. Only library-pattern names
  are now accepted.
- **Two tool bugs from Python-in-heredoc edits** (backslashes turned into control characters) broke a
  `sed` backreference and a string literal. Both were caught immediately. The generated asm they
  corrupted was regenerated; nothing committed was affected.

## Inference

- *Inferred:* the game reads 4 controller slots (`osContGetReadData` fills 4 × 6 bytes at
  `0x8005CE50`). This does not settle the 2-player claim; the input code does (phase 04/06).
- *Inferred:* `func_80034A70` returns `__osActiveQueue` or `__osFaultedThread` (body identical to both
  donors' names). Left unnamed; only a fault-handler thread (`0x80000774`) calls it.
- *Inferred:* `func_800304A0` (cop0 Index/EntryHi/EntryLo writes, called only by `osInitialize`) is a
  TLB reset. It becomes unreachable once `osInitialize` is the runtime's; phase 02 will show whether
  N64Recomp accepts its cop0 instructions or it needs a stub (Rayman 2 stubbed its TLB routines).

## What is not established

- Whether N64Recomp accepts shared-vram code sections with no `.rel` sections (the files are never
  relocated). Phase 02.
- Jump-table resolution when several sections share an address: N64Recomp must read the table from
  the caller's own section. Phase 02.
- Which of the 29 hardware-touching unnamed resident functions are reachable after the runtime owns
  libultra (PI manager internals, `__osDevMgrMain` at `0x8002AEA0`, a domain-2 PI handle at
  `0x80001EA0`). Link errors and phase 04 will say.

## Consequence for the plan

- *Departure (recorded in PLAN.md):* phase 01 checks **93** segments (resident + 92 files), not 92,
  because file 99 has code.
- Phase 02 enables `use_lookup_for_all_function_calls` from the start and needs a runtime table of
  librecomp-provided libultra addresses (`gen_runtime_func_table.py`, playbook 04).
