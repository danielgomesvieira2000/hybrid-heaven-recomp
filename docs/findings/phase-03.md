# Phase 03 findings — runtime harness

The working record, wrong turns included; not rewritten later.

**Gate:** met (2026-09-15). In **10 of 10** runs of `build\hybrid-heaven-recomp.exe rom.z64`
(12 s each, `tools/boot_runs.ps1`) the log shows:
- `on_init` ("entering recomp_entrypoint");
- 6 game threads created (`thread_create_callback`);
- no lookup miss or crash;
- the process alive at kill time;
- 600 screen updates.

Every run also announced the first code file load: `file 8 -> 0x80107830`.

```
cmake -B build -G Ninja "-DCMAKE_C_COMPILER=clang-cl" "-DCMAKE_CXX_COMPILER=clang-cl" "-DCMAKE_BUILD_TYPE=RelWithDebInfo" "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" "-DHH_WITH_RECOMPILED=ON" "-DHH_WITH_RUNTIME=ON"
cmake --build build --target hybrid-heaven-recomp
powershell -ExecutionPolicy Bypass -File tools/boot_runs.ps1 -Runs 10 -Seconds 12 -Env "HH_DEBUG_LOADS=1"
```

## Answer

The harness is Pilotwings 64's, which is Wave Race 64's with the game-specific parts removed. Four
things change for Hybrid Heaven:

1. **File-loader wrapper.** `src/sections.cpp` wraps the game's `file_load` (`0x8000469C`). Before
   calling the recompiled original, it tells librecomp which code file now occupies its window. It
   evicts every loaded file whose code range overlaps, partly or wholly, using
   `unload_overlay_by_id`: librecomp's `unload_overlays` exits on a partial overlap, and file 10
   sits inside file 26's range.
2. **Runtime-provided libultra** is registered at its cartridge addresses (63 functions,
   `tools/gen_runtime_func_table.py`), because every call is a lookup.
3. **Controller Pak.** Rayman 2's joybus layer (`src/si_pak.cpp`) and 32 KiB store
   (`src/controller_pak.cpp`) are in, and port 1 reports `Pak::ControllerPak`. Not exercised yet.
4. **Failed lookups.** They go to the fork's `set_lookup_failure_handler`, which reports the address,
   the thread's last 32 resolved addresses and the loaded files, then ends the process with
   `TerminateProcess` (no teardown race).

## Measurements

| What | Result |
|---|---|
| Link | clean at first attempt; **no undefined symbols**. With `use_lookup_for_all_function_calls` the generated code references no `<name>_recomp` directly, so an unimplemented libultra function shows up as a lookup miss at run time, not a link error |
| Runtime-provided functions with a cartridge address | 62, then **63** after fixing the generator (below) |
| Settings folder | `%LOCALAPPDATA%\hybrid-heaven-recomp` |
| Renderer | D3D12, Intel Iris Xe (the target machine) |
| Audio device | 48000 Hz, 512-frame period, 30 ms headroom |
| First file load | id 8 at `0x80107830`, as the boot code at `0x80001314` does. Ids 2, 4, 5, 7 carry no ROM data |
| Display lists in 12 s | 0 |

## Negative results

- **`gen_runtime_func_table.py` (from the framework) missed definitions written
  `(RDRAM_ARG recomp_context* ctx)`**, e.g. librecomp's `osPiStartDma` in `pi.cpp`. Its regex only
  accepted `(uint8_t* rdram, ...)`. The first table had 62 entries; `osPiStartDma` was missing and
  would have been a lookup miss at the game's first DMA. Fixed to accept both spellings (framework
  finding for the retro).
- **Two shell one-liners failed**: a PowerShell loop with a regex was refused by the tool's path
  guard (`\d+` read as a path), and a Python heredoc mangled backslashes again. Replaced by
  `tools/boot_runs.ps1` and the Edit tool.

## What is not established

- Why no display list is submitted after file 8 loads. Phase 04 starts there.
- The `thread_create_callback`'s `r4` prints `0x00000000` for the first two threads and
  `0x8005C4B0` for the next four. That is the value in `$a0` at the callback, not necessarily the
  entry point. The log label says "entry" (copied from Pilotwings) and should not be read literally.

## Consequence for the plan

Phase 04 entry met.
