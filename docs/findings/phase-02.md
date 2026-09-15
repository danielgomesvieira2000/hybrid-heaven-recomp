# Phase 02 findings — first recompile

The working record, wrong turns included; not rewritten later.

**Gate:** met (2026-09-15).
- N64Recomp translated the ELF with 0 errors and 0 warnings, into 80 source files.
- Functions emitted = 15,851 = 15,947 FUNC symbols − 96 the runtime owns by name
  (`tools/count_recompiled.py` fails on any mismatch).
- RSPRecomp produced `aspMain_rsp.cpp`.
- All of it compiles with clang-cl into `build/hh_recompiled.lib` (29 MB, 18 s on 12 cores).

Reproduce:

```
wsl -d Ubuntu -e bash tools/regenerate.sh      # split, ELF, verify, jal audit, recompile
cmake -B build -G Ninja "-DCMAKE_C_COMPILER=clang-cl" "-DCMAKE_CXX_COMPILER=clang-cl" "-DCMAKE_BUILD_TYPE=RelWithDebInfo" "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" "-DHH_WITH_RECOMPILED=ON"
cmake --build build --target hh_recompiled
```

## Answer

Three blockers stood between the phase-01 ELF and a complete translation. Each was a libultra
routine that splat or the naming pass had not yet described correctly:
- a TLB reset (stubbed);
- the eight 64-bit float conversions (named, so they are owned by the runtime);
- the exception handler's `send_mesg` tail (named).

With `use_lookup_for_all_function_calls`, 28 sections sharing one address and no `.rel`
sections gave the recompiler no trouble.

## Measurements

| Run | Stopped at | Cause | Fix |
|---|---|---|---|
| 1 | `func_800304A0`: `Unhandled cop0 register in mfc0: 10` | TLB reset (cop0 Index/EntryHi/EntryLo, `tlbwi`), called only by `osInitialize` | `stubs` (the runtime owns `osInitialize`; no TLB-mapped code) |
| 2 | `func_80034A80`: `Unhandled instruction: trunc.l.d` | libultra `ll_cvt`: 8 routines identified by FPU opcode | named `__d_to_ll` … `__ull_to_f` (N64Recomp's ignored set) |
| 3 | `func_800275E4`: `branching outside of the function (to 0x800275B4)` | the tail of `__osException`, jal'd 10× from its dispatch and ending in a branch back into it | named `send_mesg` (ignored set) |
| 4 | — | complete | — |

| Count | Value | Tool |
|---|---|---|
| FUNC symbols in the ELF | 15,947 | `count_recompiled.py` |
| owned by the runtime by name (reimplemented or ignored) | 96 | same |
| functions emitted (including 1 stub body) | 15,851 | same |
| N64Recomp "Function count" | 40,521 | includes 24,574 zero-instruction entries N64Recomp creates for OBJECT/NOTYPE symbols (lookup only; `elf.cpp:99`) |
| declarations in `reimplemented_decls.h` | 440 (116 reimplemented + 384 ignored + 83 renamed, deduplicated) | `gen_reimplemented_decls.py` |
| generated sources | 80 × `funcs_NN.c` (200 functions each), `recomp_overlays.inl` 1.4 MB, `lookup.cpp`, `aspMain_rsp.cpp` | |
| `[Info] Indirect tail call in recomp_entrypoint` | expected: the entry stub ends `jr $t2` to `0x80001078`, which must be registered at run time | |

### The port must supply

These are ignored by name, called by recompiled game code, and not implemented by librecomp at
`b0b2b6e` (`librecomp/src/math_routines.cpp` has `__f_to_ll`, `__ll_to_f`, `__ull_to_d`,
`__ull_to_f`):

| Function | Called by the game? |
|---|---|
| `__d_to_ull` | yes: `0x80001454`, files 10 and 24 |
| `__d_to_ll`, `__f_to_ull`, `__ll_to_d` | no JAL caller found; defined anyway, since linking will tell |

The full set is whatever the phase-03 link reports undefined (playbook 03, "functions nobody
implements").

## Negative results

- **Widening `__osException` to cover `func_800275E4` (size `0x60C`)** did not remove the split: the
  10 `jal`s keep a label there. Verification caught a zero-size FUNC overlapping `__osException`.
  Naming the tail was the fix.

## Inference

- *Inferred:* `send_mesg` also contains libultra's `handle_CpU`, from the handwritten layout of
  `exceptasm.s`. It makes no difference to the port: both names are ignored.

## Consequence for the plan

Phase 03 entry is met. The harness needs, beyond Wave Race's:
- the file-loader wrapper;
- registration of the resident image and runtime-provided libultra at their addresses (lookup
  for all calls);
- the port-supplied `ll_cvt` routines;
- `__osSiRawStartDma` (Controller Pak, Rayman 2's `si_pak.cpp`).
