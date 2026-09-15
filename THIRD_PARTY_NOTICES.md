# Third-party notices

This project's own code (`src/`, `include/`, `patches/`, `tools/`, `recomp/`,
original artwork under `assets/`) is under the MIT License in `LICENSE`. A built
executable also contains, or ships beside, the components below. **Every release
carries their license texts in `licenses/`**, copied from the list in
`tools/third_party_licenses.txt`.

Portions of this software are copyright © The FreeType Project
(www.freetype.org). All rights reserved.

## Runtime, renderer and frontend

| Component | Role | License | Text |
|---|---|---|---|
| [N64ModernRuntime](https://github.com/N64Recomp/N64ModernRuntime) (librecomp, ultramodern; Daniel Gomes Vieira's fork, `controller-pak` branch) | the runtime the recompiled game runs on | **GPL-3.0** | `lib/N64ModernRuntime/COPYING` |
| [N64Recomp](https://github.com/N64Recomp/N64Recomp), RSPRecomp | the recompiler; its runtime headers are linked in | MIT | `lib/N64ModernRuntime/N64Recomp/LICENSE` |
| [RT64](https://github.com/rt64/rt64) and [plume](https://github.com/renderbag/plume) | the renderer | MIT | `lib/RT64/LICENSE`, `lib/RT64/src/contrib/plume/LICENSE` |
| [RecompFrontend](https://github.com/N64Recomp/RecompFrontend) (recompui, recompinput) | launcher, menus, input | **no license published** | -- (see *Open points*) |
| [RmlUi](https://github.com/mikke89/RmlUi) | UI toolkit under recompui | MIT | `lib/RecompFrontend/recompui/lib/RmlUi/LICENSE.txt` |
| [FreeType](https://freetype.org) | font rasteriser | FTL | `lib/RecompFrontend/recompui/lib/freetype-windows-binaries/LICENSE.TXT`, `FTL.TXT` |
| [lunasvg](https://github.com/sammycage/lunasvg), plutovg | SVG icons | MIT (plutovg rasteriser: FTL) | `lib/RecompFrontend/recompui/lib/lunasvg/LICENSE` |
| [SDL2](https://libsdl.org) | window, input, audio | Zlib | `lib/RT64/src/contrib/mupen64plus-win32-deps/SDL2-2.26.3/COPYING.txt` |
| [DirectX Shader Compiler](https://github.com/microsoft/DirectXShaderCompiler) (dxcompiler.dll, dxil.dll) | shader compilation, Windows | Microsoft terms, with MIT and LLVM parts | `licenses/dxc-*.txt` |

## Libraries compiled in

The full list (ImGui, hlsl++, xxHash, zstd, miniz, o1heap, concurrentqueue,
nlohmann/json, stb, ddspp, re-spirv, Vulkan headers, volk, VMA, D3D12MA, ...) and
their license paths is in `tools/third_party_licenses.txt`. Copy the table rows
from Wave Race 64: Recompiled's THIRD_PARTY_NOTICES.md and trim what this port
does not link.

| Component | Role | License | Text |
|---|---|---|---|
| | | | |

## Fonts

| Component | Role | License | Text |
|---|---|---|---|
| Lato, Noto Emoji | menu fonts, from RmlUi's samples | OFL 1.1 | `lib/RecompFrontend/recompui/lib/RmlUi/Samples/assets/LICENSE.txt` |
| [PromptFont](https://github.com/Shinmera/promptfont) | controller glyphs | OFL 1.1 | `assets/promptfont/LICENSE.txt` |

## Symbol and decompilation sources

No decompilation of Hybrid Heaven exists. Function boundaries come from splat run on the
user's own dump.

| Source | License | Use |
|---|---|---|
| [klorfmorf/mnsg](https://github.com/klorfmorf/mnsg) (Mystical Ninja Starring Goemon decompilation) | none published | names only, matched by function body; cloned into `reference/` (ignored); nothing copied |
| [k64ret/cv64](https://github.com/k64ret/cv64) (Castlevania decompilation) | none published | same |
| [klorfmorf/Goemon64Recomp](https://github.com/klorfmorf/Goemon64Recomp) | GPL-3.0 | design reference for the file-loader seam; no code copied |

## Open points

- **RecompFrontend publishes no license.** Without one, no permission to copy or
  redistribute it exists beyond what its authors grant. This project uses it as a
  submodule and does not vendor a copy; anyone distributing a built executable
  should resolve this with its authors first.
- **The DirectX Shader Compiler's Microsoft terms** attach conditions to
  redistributing its DLLs beside a GPL-3.0 executable; not established here.

## What this means for a built executable

The runtime is GPL-3.0 and statically linked, so **any executable built from this
project is a combined work under the GNU GPL, version 3**. Whoever distributes one
must make its corresponding source available: this repository at the commit the
binary was built from, with the submodules it pins.

## Artwork

None yet.
