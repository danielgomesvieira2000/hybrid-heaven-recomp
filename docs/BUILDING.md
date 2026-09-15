# Building Hybrid Heaven: Recompiled

Step by step, as far as the project has got (see [PLAN.md](PLAN.md) for the phase). Every
step that touches the dump runs on your machine; nothing it produces is committed.

You need your own dump of **Hybrid Heaven (USA)**, SHA-1
`16dbc21620b52deab5c5abf8a309ac60adfbee85`. Put it in the repository root as `rom.z64`
(git-ignored).

## Requirements

| Tool | Where | Notes |
|---|---|---|
| Git | Windows | submodules |
| CMake ≥ 3.20, Ninja | Windows | |
| LLVM (clang-cl) | Windows | **clang-cl, not clang++** (RT64/RecompFrontend add `/W4`); never GCC |
| Visual Studio 2022 Build Tools | Windows | Windows SDK + CRT for clang-cl |
| Python ≥ 3.10 | Windows | `tools/` |
| WSL2 Ubuntu with `cmake ninja-build clang binutils-mips-linux-gnu python3` | WSL | N64Recomp and RSPRecomp run under Linux (the Windows build overflows its stack writing large output) |

`powershell -File tools/check_toolchain.ps1` reports what is present.

## 1. Clone and patch the submodules

```powershell
git clone --recurse-submodules <repo>
cd hybrid-heaven-recomp
python tools/patch_all.py      # idempotent; rerun after any submodule update
```

`git submodule status` must show:

| Submodule | Commit |
|---|---|
| `lib/N64ModernRuntime` (`danielgomesvieira2000/N64ModernRuntime`, `controller-pak`) | `b0b2b6e` |
| `lib/RT64` | `5473732` |
| `lib/RecompFrontend` | `b1a1477` |

If RT64 shows anything else (a fresh `git submodule add` checks out upstream HEAD), run
`git -C lib/RT64 checkout 5473732 && git -C lib/RT64 submodule update --init --recursive`.

## 2. Check the dump

```powershell
python tools/identify_rom.py rom.z64      # exits 0 only for the supported dump
```

## 3. Build the recompiler (WSL)

```powershell
wsl -d Ubuntu -e bash tools/wsl_build_recompiler.sh
```

Produces `lib/N64ModernRuntime/N64Recomp/build-linux/N64Recomp` and `RSPRecomp`. Rerun after
`patch_all.py` changes N64Recomp.

## 4. Configure and build (Windows)

Phase 00 tree (identification only):

```powershell
cmake -B build -G Ninja "-DCMAKE_C_COMPILER=clang-cl" "-DCMAKE_CXX_COMPILER=clang-cl" "-DCMAKE_BUILD_TYPE=RelWithDebInfo" "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
cmake --build build
build\hybrid-heaven-recomp.exe --identify rom.z64
```

Quote every `-D` argument in PowerShell (it splits `3.5` at the dot). Never build Debug:
it breaks audio timing. Delete `build/` when switching compilers.

Later phases add `-DHH_WITH_RECOMPILED=ON -DHH_WITH_RUNTIME=ON -DHH_WITH_FRONTEND=ON` and the
ROM → ELF → C steps before this one.
