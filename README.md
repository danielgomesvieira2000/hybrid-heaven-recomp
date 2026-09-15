# Hybrid Heaven: Recompiled

> **Status: 0.1.0, very early and very untested.** Only the start of the game has been played
> so far. Please report what breaks.

A native PC port of Hybrid Heaven for Windows and Linux, made by statically
recompiling the game with [N64Recomp](https://github.com/N64Recomp/N64Recomp).
Unofficial, and not affiliated with Konami.

**No game data is included.** You need your own dump of **Hybrid Heaven (USA)**
(SHA-1 `16dbc21620b52deab5c5abf8a309ac60adfbee85`), as `.z64`, `.n64`, `.v64` or a ZIP. No other version works.

## Features

- Widescreen at your window's aspect ratio, with the game's overscan border removed
- HUD elements anchored to the screen edges (the radar so far)
- Launcher with graphics, sound and controls settings, remapping and mod support
- Keyboard and controller support for 1–2 players; controllers are assigned as they are plugged in
- Controller Pak saves, and the Rumble Pak on the same controller without swapping
- F1 debug menu with a live HUD editor

Planned: high frame rate (smooth motion up to your display's refresh rate, with the game's own timing).

## Getting started

1. Download the build for your system from [Releases](../../releases).
2. Extract it and run `hybrid-heaven-recomp.exe` (Windows) or `./hybrid-heaven-recomp.sh` (Linux).
3. Pick your dump in the launcher.

## Building from source

Linux (Debian/Ubuntu, or WSL):

```sh
bash tools/setup_linux.sh --install
bash tools/build_linux.sh "/path/to/Hybrid Heaven (USA).z64"
./build-linux/hybrid-heaven-recomp
```

Windows needs Visual Studio Build Tools with clang-cl, CMake, Ninja, Python and WSL (the ELF step);
the steps are in [docs/BUILDING.md](docs/BUILDING.md), which also lists the default controls.

## Documentation

- [How the port works](docs/PORTING.md)
- [Game internals](docs/GAME-INTERNALS.md)
- [Plan](docs/PLAN.md)
- [Changelog](CHANGELOG.md)

## Credits

- [N64Recomp and N64ModernRuntime](https://github.com/N64Recomp) by Mr-Wiseguy and contributors
- [RT64](https://github.com/rt64/rt64) by Dario and contributors
- [RecompFrontend](https://github.com/N64Recomp/RecompFrontend) by the N64Recomp contributors
- [PromptFont](https://github.com/Shinmera/promptfont) by Yukari "Shinmera" Hafner, for the controller glyphs
- The LZKN64 format and the Nisitenma-Ichigo file table were read from the game's own code; [Goemon64Recomp](https://github.com/klorfmorf/Goemon64Recomp) by klorfmorf showed that this Konami engine family recompiles
- The launcher, harness and tooling come from [Wave Race 64: Recompiled](https://github.com/danielgomesvieira2000/wave-race-64-recomp)

Every third-party component and its license is listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## AI use

This project was built with Claude Code. Its code, patches, tools, documentation
and artwork were written by Claude (Anthropic), directed and tested by Daniel
Gomes Vieira. The libraries and research it builds on are the work of the people
credited above.

## License

The project's own code is [MIT](LICENSE). A built executable links
N64ModernRuntime (GPL-3.0), so a distributed binary is a GPL-3.0 combined work
whose source is this repository at the release's tag. The executable contains
the game's code, recompiled from a dump; Hybrid Heaven is the property of Konami.
