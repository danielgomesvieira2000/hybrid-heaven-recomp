#pragma once

// A read-only census of what one display list draws, for phase 07's
// measurements (playbook 08: measure the drawn region, the frustum and the 2D
// before building widescreen).
//
// HH_DL_CENSUS=<n> walks every n-th top-level display list the game submits,
// following calls and branches, and prints one report: the viewports, scissors
// and projection matrices it sets (with each perspective's aspect, vertical field
// of view and near/far planes), how many triangles it draws under each, and
// every fill and texture rectangle with its extent in the game's 320x240. Nothing
// in the list is changed. Unset, it costs one branch per list.
//
// F3DEX2 opcodes: Hybrid Heaven's graphics microcode is F3DEX2 fifo 2.06
// (docs/GAME-INTERNALS.md).

#include <cstdint>

namespace hh::dlcensus {

// Whether a census is wanted for this list. Cheap; call for every list.
bool wanted();

// Walks the list at `list_address` (a KSEG0 or physical address) in `rdram`.
void run(const uint8_t* rdram, uint32_t list_address);

// HH_FULL_FRAME=1 (phase 07, off until signed off): every G_SETSCISSOR equal to
// the game's overscan inset -- 16,8..304,232 at 320x240, 32,16..608,464 at
// 640x480 -- is rewritten in place to the full frame, so the picture reaches the
// window's edges and RT64 treats the frame as one it can widen. Other scissors
// (the hi-res letterbox, split views) are left alone.
bool overscan_fix_enabled();
void snap_overscan(uint8_t* rdram, uint32_t list_address);

}  // namespace hh::dlcensus
