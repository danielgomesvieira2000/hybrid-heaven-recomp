// Section registration, the file loader wrapper, and failed-lookup reports.
//
// This is the one translation unit that includes the generated section tables
// (their symbols are `static`).
//
// Hybrid Heaven keeps 94% of its code in compressed files it loads itself from
// its Nisitenma-Ichigo table (docs/GAME-INTERNALS.md). The recompiled code for
// every file exists from the start, in sections whose ROM addresses are the
// synthetic offsets in include/hh/file_table.h; what librecomp needs is to be told
// which file occupies which address *now*, because every call is resolved by
// address (use_lookup_for_all_function_calls) and 28 files share 0x801E1BE0.
//
// Loads pass through one of the game's two loaders: file_load(id, dest) at
// 0x8000469C, which loads a file in one call, and the streamed loader at
// 0x80004838, which loads it a piece per call (playbook 04, "announce every load";
// the second was missed until issue 001). Both are
// wrapped, not replaced: the wrapper updates librecomp's function map, then runs
// the recompiled original, which decompresses the file into RDRAM as the game
// expects -- the game reads its data from those bytes, even though its code is
// never executed from them.

#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <mutex>
#include <vector>

#if defined(_WIN32)
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#endif

#include "recomp.h"
#include "librecomp/overlays.hpp"
#include "librecomp/sections.h"

#include "recomp_overlays.inl"
#include "runtime_funcs.inl"

#include "hh/callbacks.h"
#include "hh/file_table.h"

extern "C" void file_load(uint8_t* rdram, recomp_context* ctx);
extern "C" void hh_report_lookup_miss(unsigned int addr, void* return_address);
extern "C" void unload_overlay_by_id(uint32_t id);
extern "C" void load_overlay_by_id(uint32_t id, uint32_t ram_addr);

namespace {

constexpr uint32_t kFileLoadAddress = 0x8000469C;
constexpr size_t kFileCount = sizeof(hh::kCodeFiles) / sizeof(hh::kCodeFiles[0]);

bool env_set(const char* name) {
    const char* v = std::getenv(name);
    return v != nullptr && *v != '\0' && *v != '0';
}

std::mutex g_load_mutex;
// Overlay id (index into kCodeFiles, which is also the order of
// recomp/overlays.txt and so of overlay_sections_by_index) -> loaded address, or 0.
std::vector<uint32_t> g_loaded_at(kFileCount, 0);

int code_file_index(uint32_t id) {
    for (size_t i = 0; i < kFileCount; ++i) {
        if (hh::kCodeFiles[i].id == id) {
            return static_cast<int>(i);
        }
    }
    return -1;
}

// The address range of a file that can hold functions: its text and data (bss
// excluded). Only functions matter to the function map, and files the game loads
// end to end (9, 10, 11) touch at their bss, not their code.
uint32_t file_span(size_t index) {
    return hh::kCodeFiles[index].size;
}

void announce_load(uint32_t id, uint32_t dest) {
    const int index = code_file_index(id);
    if (index < 0) {
        return;  // a data file; nothing to register
    }
    const hh::CodeFile& file = hh::kCodeFiles[index];
    if (dest != file.vram) {
        // The recompiled code carries the file's link address in every pointer it
        // builds. Loaded anywhere else it would be wrong in ways that surface far
        // from here, so say so loudly and at once.
        std::fprintf(stderr, "[hh] file %u loaded at 0x%08X, but its code is linked at 0x%08X --"
                             " registering at the link address anyway\n", id, dest, file.vram);
        std::fflush(stderr);
    }

    std::lock_guard<std::mutex> lock(g_load_mutex);
    const uint32_t lo = file.vram;
    const uint32_t hi = file.vram + file_span(index);
    size_t evicted = 0;
    for (size_t i = 0; i < kFileCount; ++i) {
        if (g_loaded_at[i] == 0) {
            continue;
        }
        const uint32_t olo = g_loaded_at[i];
        const uint32_t ohi = olo + file_span(i);
        if (olo < hi && lo < ohi) {
            // Overlapping, whether wholly or partly (file 10 sits inside file 26's
            // range). librecomp's unload_overlays exits on a partial overlap;
            // unload_overlay_by_id only erases entries that still belong to the
            // section it names, so evicting in any order is safe.
            unload_overlay_by_id(static_cast<uint32_t>(i));
            g_loaded_at[i] = 0;
            ++evicted;
        }
    }
    load_overlay_by_id(static_cast<uint32_t>(index), file.vram);
    g_loaded_at[index] = file.vram;

    static const bool trace = env_set("HH_DEBUG_LOADS");
    if (trace || dest != file.vram) {
        // The last addresses this thread resolved before the loader: the caller
        // chain, in game addresses ($ra is not maintained by recompiled code).
        recomp::overlays::LookupHistoryEntry history[recomp::overlays::lookup_history_capacity];
        const size_t n = recomp::overlays::get_lookup_history(history, recomp::overlays::lookup_history_capacity);
        std::fprintf(stderr, "[hh-load] file %3u -> 0x%08X (0x%06X bytes, %zu evicted) after",
                     id, dest, file.size, evicted);
        for (size_t i = n > 6 ? n - 6 : 0; i < n; ++i) {
            std::fprintf(stderr, " %08X", history[i].address);
        }
        std::fprintf(stderr, "\n");
        std::fflush(stderr);
    }
}

uint8_t* g_rdram = nullptr;  // for the lookup-miss report

// The game's second loader: file_load_streamed(id, dest) at 0x80004838 loads the
// same file table entry a piece per call (its own resumable LZKN64 decompressor,
// 0x80003F44, state at 0x800892B0 + 0x42AD..0x42F8), returning 0 until the file
// is complete and the end address once it is. The load queue (0x80004530,
// 0x800045C0) streams file 57, the battle code, in this way during the first
// encounter's cutscene; file_load never sees it (issue 001). The file is
// announced on the call that completes it: before that its code is not all in
// RDRAM, and the files it overwrites are still the registered ones.
constexpr uint32_t kFileLoadStreamedAddress = 0x80004838;
extern "C" void func_80004838_5438(uint8_t* rdram, recomp_context* ctx);
void file_load_streamed_hook(uint8_t* rdram, recomp_context* ctx) {
    const uint32_t id = static_cast<uint32_t>(ctx->r4);
    const uint32_t dest = static_cast<uint32_t>(ctx->r5);
    func_80004838_5438(rdram, ctx);
    if (ctx->r2 != 0) {
        announce_load(id, dest);
    }
}

// HH_DEBUG_LOADS=1 also traces lzkn64_decompress, which file_load uses (the
// streamed loader has its own decompressor and is not traced here).
extern "C" void lzkn64_decompress(uint8_t* rdram, recomp_context* ctx);
constexpr uint32_t kLzknDecompressAddress = 0x80003824;
void lzkn64_decompress_trace(uint8_t* rdram, recomp_context* ctx) {
    recomp::overlays::LookupHistoryEntry history[recomp::overlays::lookup_history_capacity];
    const size_t n = recomp::overlays::get_lookup_history(history, recomp::overlays::lookup_history_capacity);
    std::fprintf(stderr, "[hh-lzkn] src 0x%08X -> 0x%08X (a2 0x%X) after",
                 static_cast<uint32_t>(ctx->r4), static_cast<uint32_t>(ctx->r5), static_cast<uint32_t>(ctx->r6));
    for (size_t i = n > 6 ? n - 6 : 0; i < n; ++i) {
        std::fprintf(stderr, " %08X", history[i].address);
    }
    std::fprintf(stderr, "\n");
    std::fflush(stderr);
    lzkn64_decompress(rdram, ctx);
}

// Wraps the game's file_load: register the file's functions, then load it.
void file_load_hook(uint8_t* rdram, recomp_context* ctx) {
    g_rdram = rdram;
    // Arguments are read before calling through: the callee owns the context.
    const uint32_t id = static_cast<uint32_t>(ctx->r4);
    const uint32_t dest = static_cast<uint32_t>(ctx->r5);
    announce_load(id, dest);
    file_load(rdram, ctx);
}

constexpr uint32_t kOsGetMemSizeAddress = 0x8002C0B0;
void os_get_mem_size_4mb(uint8_t* rdram, recomp_context* ctx) {
    (void)rdram;
    ctx->r2 = 4 * 1024 * 1024;
}

// HH_TRACE_AI=1: the buffer address and size the game hands osAiSetNextBuffer,
// for the first 12 calls.
extern "C" void osAiSetNextBuffer_recomp(uint8_t* rdram, recomp_context* ctx);
constexpr uint32_t kAiSetNextBufferAddress = 0x80034F70;
void ai_set_next_buffer_trace(uint8_t* rdram, recomp_context* ctx) {
    static int calls = 0;
    if (++calls <= 12) {
        std::fprintf(stderr, "[hh-ai] osAiSetNextBuffer(0x%016llX, 0x%llX)\n",
                     static_cast<unsigned long long>(ctx->r4), static_cast<unsigned long long>(ctx->r5));
        std::fflush(stderr);
    }
    osAiSetNextBuffer_recomp(rdram, ctx);
}

// librecomp's own miss path prints one line, then asserts and std::exits on the
// game thread; the exit runs static destructors under a live renderer and the
// process dies a second time in teardown (Rayman 2, playbook 04). The fork lets
// the port take the failure instead: report it with the calls that led there,
// then end the process without running any teardown.
void on_lookup_failure(int32_t addr) {
    recomp::overlays::LookupHistoryEntry history[recomp::overlays::lookup_history_capacity];
    const size_t n = recomp::overlays::get_lookup_history(history, recomp::overlays::lookup_history_capacity);
    hh_report_lookup_miss(static_cast<unsigned int>(addr), __builtin_return_address(0));
    std::fprintf(stderr, "[hh] last %zu addresses this thread resolved, oldest first:\n", n);
    for (size_t i = 0; i < n; ++i) {
        std::fprintf(stderr, "[hh]   0x%08X%s\n", history[i].address,
                     history[i].repeats > 1 ? " (repeated)" : "");
    }
    {
        std::lock_guard<std::mutex> lock(g_load_mutex);
        std::fprintf(stderr, "[hh] code files loaded:");
        for (size_t i = 0; i < kFileCount; ++i) {
            if (g_loaded_at[i] != 0) {
                std::fprintf(stderr, " %u", hh::kCodeFiles[i].id);
            }
        }
        std::fprintf(stderr, "\n");
    }
    // What the game would execute on hardware: the words in RDRAM at the target
    // say whether a file the wrapper never saw is there, or the call really lands
    // in the middle of the loaded file's code. 0x8017DD92 guards file 11's calls
    // into file 57 (docs/issues/001); 0x801BBC1C is the scene id file 8 switches
    // overlays on.
    if (uint8_t* rdram = g_rdram; rdram != nullptr && (addr & 0xFF800000) == 0x80000000) {
        const int32_t base = addr & ~3;
        std::fprintf(stderr, "[hh] RDRAM at 0x%08X: %08X %08X %08X %08X\n", static_cast<unsigned>(base),
                     static_cast<uint32_t>(MEM_W(0, base)), static_cast<uint32_t>(MEM_W(4, base)),
                     static_cast<uint32_t>(MEM_W(8, base)), static_cast<uint32_t>(MEM_W(12, base)));
        std::fprintf(stderr, "[hh] D_8017DD92 = %u, scene D_801BBC1C = 0x%04X\n",
                     static_cast<uint8_t>(MEM_BU(0, static_cast<int32_t>(0x8017DD92))),
                     static_cast<uint16_t>(MEM_HU(0, static_cast<int32_t>(0x801BBC1C))));
        // HH_MISS_DUMP=<file>: all 8 MB of RDRAM, as the runtime holds it (32-bit
        // words in host order), for comparing against the unpacked files.
        if (const char* path = std::getenv("HH_MISS_DUMP"); path != nullptr && *path != '\0') {
            if (FILE* f = std::fopen(path, "wb"); f != nullptr) {
                std::fwrite(rdram, 1, 8 * 1024 * 1024, f);
                std::fclose(f);
                std::fprintf(stderr, "[hh] RDRAM written to %s\n", path);
            }
        }
    }
    std::fflush(stdout);
    std::fflush(stderr);
#if defined(_WIN32)
    TerminateProcess(GetCurrentProcess(), 3);
#else
    std::_Exit(3);
#endif
}

}  // namespace

namespace hh {

void register_sections() {
    recomp::overlays::overlay_section_table_data_t sections{};
    sections.code_sections = section_table;
    sections.num_code_sections = ARRLEN(section_table);
    sections.total_num_sections = num_sections;

    recomp::overlays::overlays_by_index_t overlays{};
    overlays.table = overlay_sections_by_index;
    overlays.len = ARRLEN(overlay_sections_by_index);

    recomp::overlays::register_overlays(sections, overlays);
    recomp::overlays::set_lookup_failure_handler(on_lookup_failure);

    if (ARRLEN(overlay_sections_by_index) != kFileCount) {
        std::fprintf(stderr, "[hh] generated overlay table has %zu entries, file_table.h %zu:"
                             " regenerate both (tools/unpack_rom.py, tools/regenerate.sh)\n",
                     ARRLEN(overlay_sections_by_index), kFileCount);
        std::fflush(stderr);
        std::abort();
    }
}

void register_runtime_functions() {
    // Must run from on_init: init_overlays() begins with func_map.clear().
    //
    // The resident image is already registered: librecomp's boot load maps ROM
    // 0x1000 + 1 MB to the entry point, and the resident section is exactly that
    // (ROM 0x1000, linked at 0x80000400). The code files are not; they arrive
    // through file_load.
    //
    // With every call resolved by address, the libultra functions the runtime
    // provides need their cartridge addresses too (playbook 04).
    for (const auto& entry : runtime_provided_funcs) {
        recomp::overlays::add_loaded_function(static_cast<int32_t>(entry.ram_addr), entry.func);
    }

    // Last, so nothing above overwrites it.
    recomp::overlays::add_loaded_function(static_cast<int32_t>(kFileLoadAddress), file_load_hook);
    if (!env_set("HH_NO_STREAMED_LOADS")) {
        recomp::overlays::add_loaded_function(static_cast<int32_t>(kFileLoadStreamedAddress), file_load_streamed_hook);
    }
    // HH_EXPANSION_PAK=0: report a 4 MB console. The game asks only through
    // osGetMemSize (0x8002C0B0; main compares the answer with 0x400000), which the
    // runtime answers with 8 MB. For the phase-04 comparison of the two modes
    // (docs/PLAN.md D7).
    {
        const char* v = std::getenv("HH_EXPANSION_PAK");
        if (v != nullptr && *v == '0') {
            recomp::overlays::add_loaded_function(static_cast<int32_t>(kOsGetMemSizeAddress), os_get_mem_size_4mb);
            std::fprintf(stderr, "[hh] HH_EXPANSION_PAK=0: osGetMemSize reports 4 MB\n");
        }
    }
    if (env_set("HH_DEBUG_LOADS")) {
        recomp::overlays::add_loaded_function(static_cast<int32_t>(kLzknDecompressAddress), lzkn64_decompress_trace);
    }
    if (env_set("HH_TRACE_AI")) {
        recomp::overlays::add_loaded_function(static_cast<int32_t>(kAiSetNextBufferAddress), ai_set_next_buffer_trace);
    }

    std::fprintf(stderr, "[hh] registered %zu runtime-provided functions; file loader wrapped at 0x%08X\n",
                 sizeof(runtime_provided_funcs) / sizeof(runtime_provided_funcs[0]), kFileLoadAddress);
    std::fflush(stderr);
}

size_t code_section_count() {
    return ARRLEN(section_table);
}

}  // namespace hh
