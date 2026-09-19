# Changelog

Every release, newest first. Each entry links to its notes under
[`docs/releases/`](docs/releases).

Versions follow [semantic versioning](https://semver.org) loosely: while the
project is below 1.0, the minor number moves when something a player would
notice changes.

## [0.2.0](docs/releases/0.2.0.md) — First battles

- **Fixed: crash at the first enemy encounter.** The game streams the battle code (file 57) in during
  the encounter cutscene through a second loader (`0x80004838`) the port did not wrap; its functions
  were never registered and the first call into them was a lookup miss
  ([issue 001](docs/issues/001-first-enemy-lookup-miss.md); `HH_NO_STREAMED_LOADS=1` reverts).
- Diagnostics: the lookup-miss report shows the RDRAM words at the target; `HH_MISS_DUMP=<file>`
  writes all of RDRAM; `HH_DEBUG_LOADS` also traces `lzkn64_decompress`.
- `tools/test_sandbox.py`: test runs in a throwaway copy of the build.

## [0.1.0](docs/releases/0.1.0.md) — First release

Very early and very untested: only boot, menus, New Game, the opening cinematic and the first
rooms have been played.

- **Windows and Linux builds** (Linux via `tools/setup_linux.sh` / `tools/build_linux.sh`).
- **Widescreen:** the game's overscan scissor is drawn full frame, so RT64 widens the picture
  (`HH_FULL_FRAME=0` reverts).
- **HUD anchoring** through the F1 panel and a built-in table (the radar left). Identities carry
  content hashes after tags keyed by address broke the Expansion Pak screen
  (`HH_NO_HUD_REWRITE=1` reverts).
- **Frontend** from Wave Race 64: Recompiled: launcher, settings, remapping, 1–2 players, mods tab,
  F1 debug menu.
- **Controller Pak saves and Rumble Pak on one slot**, with a one-instruction patch to the game's
  slot classifier (`HH_NO_RUMBLE_PAK=1` reverts the pak answer).
- Known: no high frame rate yet; the hi-res letterbox mode is untouched; audio pitch has not been
  compared with an emulator; the rumble motor has not been seen starting in play.
