// The HUD rewriter. See include/hh/hudrewrite.h.

#include "hh/hudrewrite.h"
#include "hh/inspector.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

#define F3DEX_GBI_2
#include "rt64_extended_gbi.h"

namespace hh::hudrewrite {
namespace {

// Two scratch buffers, alternated per frame, between the end of the game's
// reservations (file 3 ends at 0x80796000) and the audio command-list copy at
// 0x807F0000 (src/callbacks.cpp). 20,000 commands each; the busiest frame
// measured is about 6,300 across all its lists (docs/findings/phase-07.md).
constexpr uint32_t kScratch[2] = { 0x007A0000u, 0x007C8000u };
constexpr uint32_t kScratchSize = 0x28000u;

// F3DEX2.
constexpr uint8_t kMtx = 0xDA, kMoveWord = 0xDB, kMoveMem = 0xDC, kDl = 0xDE, kEndDl = 0xDF;
constexpr uint8_t kTexRect = 0xE4, kTexRectFlip = 0xE5, kRdpHalf1 = 0xE1, kRdpHalf2 = 0xF1;
constexpr uint8_t kSetScissor = 0xED, kFillRect = 0xF6, kSetFillColor = 0xF7, kSetTImg = 0xFD, kSetCImg = 0xFF;
constexpr uint8_t kMwSegment = 0x06, kMvViewport = 0x08, kMtxProjection = 0x04;

uint32_t read_word(const uint8_t* rdram, uint32_t phys) {
    uint32_t v;
    std::memcpy(&v, rdram + (phys & 0x7FFFFC), sizeof v);
    return v;
}

std::string hex_id(const char* kind, uint32_t value) {
    char buf[32];
    std::snprintf(buf, sizeof buf, "%s:0x%08x", kind, value);
    return buf;
}

int class_of(const std::string& identity) {
    return hh::inspector::class_for(identity.c_str());
}

// HH_HUD_REWRITE_TRACE=1: each identity the rewriter sees, once, with its class
// and where it was met (rect in a list, or a call).
void trace_seen(const std::string& identity, const char* where, int cls) {
    static const bool on = std::getenv("HH_HUD_REWRITE_TRACE") != nullptr;
    if (!on) return;
    static std::vector<std::string> seen;
    for (const auto& s : seen) if (s == identity) return;
    if (seen.size() > 200) return;
    seen.push_back(identity);
    std::fprintf(stderr, "[hh-hud] %s %s class %d\n", where, identity.c_str(), cls);
    std::fflush(stderr);
}

struct Writer {
    uint8_t* rdram;
    uint32_t base, size;
    uint32_t used = 0;
    bool overflow = false;

    uint32_t segments[16] = {};
    uint32_t fb_width = 320;
    bool have_viewport = false, have_scissor = false, have_projection = false;
    uint32_t viewport_w0 = 0, viewport_w1 = 0, scissor_w0 = 0, scissor_w1 = 0;
    uint32_t projection_w0 = 0, projection_w1 = 0;
    uint32_t image = 0, fill_colour = 0;
    int applied = 0;

    uint32_t physical(uint32_t address) const {
        if ((address >> 24) >= 0x80) return address & 0x1FFFFFFF;
        return (segments[(address >> 24) & 0x0F] + (address & 0x00FFFFFF)) & 0x1FFFFFFF;
    }

    GfxCommand* reserve(uint32_t count) {
        if (used + 8 * count > size) {
            overflow = true;
            return nullptr;
        }
        GfxCommand* cmd = reinterpret_cast<GfxCommand*>(rdram + base + used);
        used += 8 * count;
        return cmd;
    }
    void emit(uint32_t w0, uint32_t w1) {
        if (GfxCommand* cmd = reserve(1)) {
            cmd->values.word0 = w0;
            cmd->values.word1 = w1;
        }
    }
    void enable() {
        if (GfxCommand* cmd = reserve(1)) gEXEnable(cmd);
    }

    // RT64 displaces an aligned coordinate by origin / 1024 of the framebuffer's
    // width, in quarter pixels; this undoes it, so the game's own numbers are
    // measured from the chosen edge (Wave Race 64).
    int origin_cancel(uint32_t origin) const {
        return -static_cast<int>((origin * fb_width * 4) / G_EX_ORIGIN_RIGHT);
    }

    // A scissor spanning the widened frame with the game's vertical bounds: its
    // edges anchored left and right, its numbers given relative to those anchors
    // so RT64's stored rectangle -- and every coverage test made against it --
    // stays the game's (Wave Race 64's second attempt; the first cost the 3D
    // pass its widescreen).
    void widen_scissor() {
        if (!have_scissor) return;
        const uint8_t mode = static_cast<uint8_t>((scissor_w1 >> 24) & 3);
        const int ulx = static_cast<int>((scissor_w0 >> 12) & 0xFFF) >> 2;
        const int uly = static_cast<int>(scissor_w0 & 0xFFF) >> 2;
        const int lrx = static_cast<int>((scissor_w1 >> 12) & 0xFFF) >> 2;
        const int lry = static_cast<int>(scissor_w1 & 0xFFF) >> 2;
        if (GfxCommand* cmd = reserve(2)) {
            gEXSetScissor(cmd, mode, G_EX_ORIGIN_LEFT, G_EX_ORIGIN_RIGHT, ulx, uly,
                          lrx - static_cast<int>(fb_width), lry);
        }
    }
    void restore_scissor() {
        if (have_scissor) emit(scissor_w0, scissor_w1);
    }

    void projection_group(uint32_t aspect) {
        if (GfxCommand* cmd = reserve(2)) {
            gEXMatrixGroup(cmd, G_EX_ID_AUTO, G_EX_INTERPOLATE_SIMPLE, G_EX_NOPUSH, 1,
                           G_EX_COMPONENT_SKIP, G_EX_COMPONENT_SKIP, G_EX_COMPONENT_SKIP,
                           G_EX_COMPONENT_SKIP, G_EX_COMPONENT_SKIP, G_EX_COMPONENT_SKIP,
                           G_EX_COMPONENT_SKIP, G_EX_ORDER_AUTO, G_EX_EDIT_NONE, aspect,
                           G_EX_COMPONENT_SKIP, G_EX_COMPONENT_SKIP);
        }
        if (have_projection) emit(projection_w0, projection_w1);
    }

    void viewport_align(uint32_t origin, int offset) {
        if (GfxCommand* cmd = reserve(2)) gEXSetViewportAlign(cmd, origin, offset, 0);
        if (have_viewport) emit(viewport_w0, viewport_w1);
    }

    // ---- rectangles ----
    void rect_begin(int cls) {
        switch (cls) {
            case hh::inspector::kLeft:
                widen_scissor();
                if (GfxCommand* cmd = reserve(2)) gEXSetRectAlign(cmd, G_EX_ORIGIN_LEFT, G_EX_ORIGIN_LEFT, 0, 0, 0, 0);
                break;
            case hh::inspector::kRight: {
                widen_scissor();
                const int off = origin_cancel(G_EX_ORIGIN_RIGHT);
                if (GfxCommand* cmd = reserve(2)) gEXSetRectAlign(cmd, G_EX_ORIGIN_RIGHT, G_EX_ORIGIN_RIGHT, off, 0, off, 0);
                break;
            }
            case hh::inspector::kStretch:
                if (GfxCommand* cmd = reserve(1)) gEXSetRectAspect(cmd, G_EX_ASPECT_STRETCH);
                break;
            case hh::inspector::kSpill:
                widen_scissor();
                break;
            default:
                break;
        }
    }
    void rect_end(int cls) {
        switch (cls) {
            case hh::inspector::kLeft:
            case hh::inspector::kRight:
                if (GfxCommand* cmd = reserve(2)) gEXSetRectAlign(cmd, G_EX_ORIGIN_NONE, G_EX_ORIGIN_NONE, 0, 0, 0, 0);
                restore_scissor();
                break;
            case hh::inspector::kStretch:
                if (GfxCommand* cmd = reserve(1)) gEXSetRectAspect(cmd, G_EX_ASPECT_AUTO);
                break;
            case hh::inspector::kSpill:
                restore_scissor();
                break;
            default:
                break;
        }
    }

    // ---- triangle groups (a called list) ----
    void group_begin(int cls) {
        switch (cls) {
            case hh::inspector::kLeft:
                widen_scissor();
                viewport_align(G_EX_ORIGIN_LEFT, origin_cancel(G_EX_ORIGIN_LEFT));
                break;
            case hh::inspector::kRight:
                widen_scissor();
                viewport_align(G_EX_ORIGIN_RIGHT, origin_cancel(G_EX_ORIGIN_RIGHT));
                break;
            case hh::inspector::kStretch:
                projection_group(G_EX_ASPECT_STRETCH);
                break;
            case hh::inspector::kSpill:
                widen_scissor();
                break;
            default:
                break;
        }
    }
    void group_end(int cls) {
        switch (cls) {
            case hh::inspector::kLeft:
            case hh::inspector::kRight:
                viewport_align(G_EX_ORIGIN_NONE, 0);
                restore_scissor();
                break;
            case hh::inspector::kStretch:
                projection_group(G_EX_ASPECT_AUTO);
                break;
            case hh::inspector::kSpill:
                restore_scissor();
                break;
            default:
                break;
        }
    }

    // Copies the list at `address` (and, recursively, the lists it calls) into
    // the scratch buffer and returns the copy's KSEG0 address.
    uint32_t copy_list(uint32_t address, int depth) {
        const uint32_t start = used;
        int branch_cls = hh::inspector::kAuto;   // class of the branch target being inlined
        enable();   // RT64 forgets the extended GBI at the end of every list
        uint32_t pc = physical(address);
        for (int guard = 0; guard < 40000 && !overflow; ++guard) {
            if (pc >= 0x800000) break;
            const uint32_t w0 = read_word(rdram, pc);
            const uint32_t w1 = read_word(rdram, pc + 4);
            const uint8_t op = static_cast<uint8_t>(w0 >> 24);
            pc += 8;
            switch (op) {
                case kEndDl:
                    if (branch_cls != hh::inspector::kAuto) group_end(branch_cls);
                    emit(w0, w1);
                    return 0x80000000u | (base + start);
                case kDl: {
                    const bool branch = ((w0 >> 16) & 0xFF) != 0;
                    if (branch) {
                        // A branch never returns: its list's end command is this
                        // list's end. A classified branch target (the radar dial is
                        // one, dl:0x80181860) is therefore wrapped from here to that
                        // end command.
                        const int cls = class_of(hex_id("dl", w1));
                        trace_seen(hex_id("dl", w1), "branch", cls);
                        if (branch_cls != hh::inspector::kAuto) group_end(branch_cls);
                        branch_cls = cls;
                        if (cls != hh::inspector::kAuto) {
                            group_begin(cls);
                            ++applied;
                        }
                        pc = physical(w1);   // follow it inline
                        break;
                    }
                    const int cls = depth < 10 ? class_of(hex_id("dl", w1)) : hh::inspector::kAuto;
                    trace_seen(hex_id("dl", w1), "call", cls);
                    // The callee is copied first, after this list's commands so far,
                    // so write the call's placeholder, then the callee, and patch.
                    uint32_t callee = w1;
                    if (depth < 10) {
                        // Reserve a jump over the callee's copy.
                        const uint32_t jump_at = used;
                        emit(0, 0);
                        uint32_t copied = copy_list(w1, depth + 1);
                        if (overflow) return 0;
                        const uint32_t after = used;
                        // Rewrite the placeholder as a no-push branch to `after`.
                        const uint32_t jw0 = (static_cast<uint32_t>(kDl) << 24) | (1u << 16);
                        const uint32_t jw1 = 0x80000000u | (base + after);
                        std::memcpy(rdram + base + jump_at, &jw0, 4);
                        std::memcpy(rdram + base + jump_at + 4, &jw1, 4);
                        callee = copied;
                    }
                    group_begin(cls);
                    emit(w0, callee);
                    enable();
                    group_end(cls);
                    if (cls != hh::inspector::kAuto) ++applied;
                    break;
                }
                case kMoveWord:
                    if (((w0 >> 16) & 0xFF) == kMwSegment) {
                        segments[((w0 & 0xFFFF) / 4) & 0x0F] = w1 & 0x1FFFFFFF;
                    }
                    emit(w0, w1);
                    break;
                case kMoveMem:
                    if ((w0 & 0xFF) == kMvViewport) {
                        have_viewport = true;
                        viewport_w0 = w0;
                        viewport_w1 = w1;
                    }
                    emit(w0, w1);
                    break;
                case kMtx:
                    if ((((w0 & 0xFF) ^ 0x01) & kMtxProjection) != 0) {
                        have_projection = true;
                        projection_w0 = w0;
                        projection_w1 = w1;
                    }
                    emit(w0, w1);
                    break;
                case kSetScissor:
                    have_scissor = true;
                    scissor_w0 = w0;
                    scissor_w1 = w1;
                    emit(w0, w1);
                    break;
                case kSetCImg:
                    fb_width = ((w1 & 0x00FFFFFF) == 0x00400000) ? 640 : 320;
                    emit(w0, w1);
                    break;
                case kSetTImg:
                    image = w1;
                    emit(w0, w1);
                    break;
                case kSetFillColor:
                    fill_colour = w1;
                    emit(w0, w1);
                    break;
                case kFillRect: {
                    const int cls = class_of(hex_id("fill", fill_colour));
                    trace_seen(hex_id("fill", fill_colour), "fill rect", cls);
                    rect_begin(cls);
                    emit(w0, w1);
                    rect_end(cls);
                    if (cls != hh::inspector::kAuto) ++applied;
                    break;
                }
                case kTexRect:
                case kTexRectFlip: {
                    const int cls = class_of(hex_id("tex", image));
                    trace_seen(hex_id("tex", image), "tex rect", cls);
                    rect_begin(cls);
                    emit(w0, w1);
                    for (uint8_t half : { kRdpHalf1, kRdpHalf2 }) {
                        const uint32_t h0 = read_word(rdram, pc);
                        if (static_cast<uint8_t>(h0 >> 24) == half) {
                            emit(h0, read_word(rdram, pc + 4));
                            pc += 8;
                        }
                    }
                    rect_end(cls);
                    if (cls != hh::inspector::kAuto) ++applied;
                    break;
                }
                default:
                    emit(w0, w1);
                    break;
            }
        }
        // Ran off the end or out of room: not safe to submit.
        overflow = true;
        return 0;
    }
};

int g_turn = 0;

}  // namespace

uint32_t rewrite(uint8_t* rdram, uint32_t list_address) {
    static const bool off = [] {
        const char* v = std::getenv("HH_NO_HUD_REWRITE");
        return v != nullptr && *v != '\0' && *v != '0';
    }();
    if (off || !hh::inspector::any_classes()) return 0;

    g_turn ^= 1;
    Writer w{ rdram, kScratch[g_turn], kScratchSize };
    const uint32_t copy = w.copy_list(list_address, 0);
    static bool reported_overflow = false;
    if (w.overflow || copy == 0) {
        if (!reported_overflow) {
            reported_overflow = true;
            std::fprintf(stderr, "[hh] HUD rewrite: a list did not fit or did not end (%u bytes used); submitted unchanged\n",
                         w.used);
            std::fflush(stderr);
        }
        return 0;
    }
    static int reported = 0;
    if (w.applied > 0 && reported < 3) {
        ++reported;
        std::fprintf(stderr, "[hh] HUD rewrite: %d classified element draw(s) in a %u-byte copy\n", w.applied, w.used);
        std::fflush(stderr);
    }
    return copy;
}

}  // namespace hh::hudrewrite
