// Let a busy-waiting game thread give the scheduler a turn.
//
// libultra's scheduler is preemptive; ultramodern's is not. It reschedules, and
// delivers VI/SP/DP/PI/SI events from outside the game, only inside
// osSendMesg/osRecvMesg/osJamMesg. A game thread that loops without calling one
// of those stops every other game thread and every external event (playbook 05,
// "Threads and cooperative scheduling"; hit by Rayman 2, Beetle Adventure Racing
// and Pilotwings 64 before this port).
//
// Hybrid Heaven's main loop ends each frame in a frame limiter that polls the
// clock until enough time has passed (func_80001454, 0x80001A88-0x80001B18):
//
//     target = func_80133AA0();
//     do { elapsed = (osGetTime() - start) * 64 / 3000 / k; } while (elapsed < target);
//
// osGetTime calls nothing that yields. recomp/hybrid-heaven.us.toml hooks the top
// of that loop to call this, which does what the counter interrupt would have:
// deliver a pending external message and let a higher-priority runnable thread
// run.
//
// Taken from Rayman 2: Recompiled (src/spin_yield.cpp), including its measured
// choice of a 1 ms bounded wait over a hot poll (a hot poll starved the native
// renderer and audio threads there).

#include <cstdint>
#include <cstdio>
#include <cstdlib>

#include "ultramodern/ultramodern.hpp"

namespace {

// HH_YIELD_MS=<n>: how long a spinning thread waits for an external message
// before giving the scheduler a turn. 1 ms by default; clamped to 0-100.
uint32_t yield_timeout_ms() {
    static const uint32_t ms = []() -> uint32_t {
        const char* value = std::getenv("HH_YIELD_MS");
        if (value == nullptr) {
            return 1;
        }
        const long parsed = std::strtol(value, nullptr, 10);
        const uint32_t clamped = static_cast<uint32_t>(parsed < 0 ? 0 : (parsed > 100 ? 100 : parsed));
        std::fprintf(stderr, "[hh] HH_YIELD_MS: spin yields wait %u ms (default 1)\n", clamped);
        return clamped;
    }();
    return ms;
}

}  // namespace

extern "C" void hh_yield_in_spin(uint8_t* rdram) {
    ultramodern::wait_for_external_message_timed(rdram, yield_timeout_ms());
    ultramodern::check_running_queue(rdram);
}
