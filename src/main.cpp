// Hybrid Heaven: Recompiled -- entry point.
//
// Phase 00. The executable identifies a dump against the pinned target and
// reports its build configuration. The runtime harness (phase 03) is added to
// this file behind HH_WITH_RUNTIME && HH_WITH_RECOMPILED; it is modelled on
// Wave Race 64: Recompiled's main.cpp.

#include "hh/crash_handler.h"
#include "hh/rom.h"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#if defined(_WIN32)
#   include <crtdbg.h>
#   include <io.h>
#   define WIN32_LEAN_AND_MEAN
#   include <windows.h>
#elif defined(__APPLE__)
#   include <mach-o/dyld.h>
#endif
#include <filesystem>
#include <string>
#include <system_error>
#include <vector>

// Set by CMake from project(VERSION ...). Defined here too so a build that
// compiles this file on its own still names a version rather than failing.
#ifndef HH_VERSION
#   define HH_VERSION "unknown"
#   define HH_VERSION_MAJOR 0
#   define HH_VERSION_MINOR 0
#   define HH_VERSION_PATCH 0
#endif

namespace hh {

// The per-user directory for settings, controller profiles, saves and mod state.
//
// On Windows this is %LOCALAPPDATA%\hybrid-heaven-recomp. On macOS it is
// ~/Library/Application Support/hybrid-heaven-recomp. On Linux and the rest it
// is $XDG_DATA_HOME/hybrid-heaven-recomp, or ~/.local/share/hybrid-heaven-recomp.
// A file called portable.txt in the working directory (the executable's
// directory, see main) keeps everything there instead.
std::filesystem::path settings_directory() {
    if (std::filesystem::exists("portable.txt")) {
        return std::filesystem::current_path();
    }
    const char* base = nullptr;
    std::filesystem::path root;
#if defined(_WIN32)
    base = std::getenv("LOCALAPPDATA");
    if (base != nullptr) {
        root = base;
    }
#elif defined(__APPLE__)
    if ((base = std::getenv("HOME")) != nullptr) {
        root = std::filesystem::path{ base } / "Library" / "Application Support";
    }
#else
    base = std::getenv("XDG_DATA_HOME");
    if (base != nullptr && *base != '\0') {
        root = base;
    }
    else if ((base = std::getenv("HOME")) != nullptr) {
        root = std::filesystem::path{ base } / ".local" / "share";
    }
#endif
    if (root.empty()) {
        return std::filesystem::current_path();
    }
    return root / "hybrid-heaven-recomp";
}

// The directory the executable is in, or empty if it cannot be found.
std::filesystem::path executable_directory(const char* argv0) {
    std::error_code ec;
#if defined(_WIN32)
    wchar_t buffer[MAX_PATH * 4];
    const DWORD length = GetModuleFileNameW(nullptr, buffer, static_cast<DWORD>(std::size(buffer)));
    if (length > 0 && length < std::size(buffer)) {
        return std::filesystem::path{ buffer }.parent_path();
    }
#elif defined(__APPLE__)
    uint32_t length = 0;
    _NSGetExecutablePath(nullptr, &length);
    std::vector<char> buffer(length);
    if (length > 0 && _NSGetExecutablePath(buffer.data(), &length) == 0) {
        const std::filesystem::path self =
            std::filesystem::weakly_canonical(buffer.data(), ec);
        if (!ec) {
            return self.parent_path();
        }
    }
#else
    const std::filesystem::path self = std::filesystem::read_symlink("/proc/self/exe", ec);
    if (!ec) {
        return self.parent_path();
    }
#endif
    const std::filesystem::path from_argv = std::filesystem::absolute(argv0, ec);
    return ec ? std::filesystem::path{} : from_argv.parent_path();
}

}  // namespace hh

namespace {

// The working directory the program was started from, kept so that a relative
// path on the command line still means what the user meant after the working
// directory is moved to the executable's (see main).
std::filesystem::path g_original_cwd;

std::string resolve_input_path(const char* path) {
    std::filesystem::path p{ path };
    if (p.is_relative() && !g_original_cwd.empty()) {
        p = g_original_cwd / p;
    }
    return p.string();
}

void print_usage(const char* argv0) {
    std::printf(
        "Hybrid Heaven: Recompiled\n"
        "\n"
        "Usage:\n"
        "  %s <rom.z64>              Run the game with the given dump\n"
        "  %s --identify <rom.z64>   Print header fields and verify the dump\n"
        "  %s --version              Print build configuration\n"
        "\n"
        "This program contains no game data. Supply your own legally obtained\n"
        "Hybrid Heaven (USA) dump.\n",
        argv0, argv0, argv0);
}

void print_version() {
    std::printf("Hybrid Heaven: Recompiled %s\n", HH_VERSION);
    std::printf("  recompiled game code : %s\n",
#if HH_WITH_RECOMPILED
        "linked");
#else
        "not built (configure with -DHH_WITH_RECOMPILED=ON)");
#endif
    std::printf("  runtime + RT64       : %s\n",
#if HH_WITH_RUNTIME
        "linked");
#else
        "not built (configure with -DHH_WITH_RUNTIME=ON)");
#endif
    std::printf("  frontend             : %s\n",
#if HH_WITH_FRONTEND
        "linked");
#else
        "not built (configure with -DHH_WITH_FRONTEND=ON)");
#endif
}

int identify(const char* path_arg) {
    const std::string resolved = resolve_input_path(path_arg);
    const char* path = resolved.c_str();
    hh::RomHeader header;
    std::string error;

    if (!hh::read_header(path, header, error)) {
        std::fprintf(stderr, "error: %s\n", error.c_str());
        return 1;
    }

    std::printf("%-16s %s\n", "file",     path);
    std::printf("%-16s %s\n", "format",   hh::to_string(header.format).c_str());
    std::printf("%-16s %llu bytes\n", "size",
                static_cast<unsigned long long>(header.size_bytes));
    std::printf("%-16s %s\n", "name",     header.internal_name.c_str());
    std::printf("%-16s %s\n", "cart id",  header.cartridge_id.c_str());
    std::printf("%-16s %c\n", "region",   header.region ? header.region : '?');
    std::printf("%-16s %u\n", "revision", header.revision);
    std::printf("%-16s 0x%08X 0x%08X\n", "header crc", header.crc1, header.crc2);

    std::vector<std::string> problems;
    if (hh::verify(header, problems)) {
        std::printf("\nThis dump matches the pinned target.\n");
        return 0;
    }

    std::printf("\nThis dump does NOT match the pinned target:\n");
    for (const std::string& problem : problems) {
        std::printf("  - %s\n", problem.c_str());
    }
    return 2;
}

}  // namespace

int main(int argc, char** argv) {
    hh::install_crash_handler();

#if defined(_WIN32) && !defined(NDEBUG)
    // Send failed assertions to stderr instead of a modal dialog, which would
    // block the thread that raised it (Wave Race: the RSP task thread).
    _CrtSetReportMode(_CRT_ASSERT, _CRTDBG_MODE_FILE);
    _CrtSetReportFile(_CRT_ASSERT, _CRTDBG_FILE_STDERR);
    _CrtSetReportMode(_CRT_ERROR, _CRTDBG_MODE_FILE);
    _CrtSetReportFile(_CRT_ERROR, _CRTDBG_FILE_STDERR);
#endif

    // Unbuffer stdout: runs are inspected through a redirected file and the
    // process is usually killed rather than exiting, which discards a buffer.
    std::setvbuf(stdout, nullptr, _IONBF, 0);

    // Run from the executable's own directory. RecompFrontend opens "assets/"
    // relative to the working directory; the original directory is remembered
    // so a dump given as a relative path still resolves against it.
    {
        std::error_code ec;
        g_original_cwd = std::filesystem::current_path(ec);
        const std::filesystem::path exe_dir = hh::executable_directory(argv[0]);
        if (!exe_dir.empty()) {
            std::filesystem::current_path(exe_dir, ec);
            if (ec) {
                std::fprintf(stderr, "[hh] could not change to %s: %s\n",
                             exe_dir.string().c_str(), ec.message().c_str());
            }
        }
    }

    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }

    const std::string command = argv[1];

    if (command == "--version" || command == "-v") {
        print_version();
        return 0;
    }

    if (command == "--identify") {
        if (argc < 3) {
            std::fprintf(stderr, "error: --identify needs a path to a .z64 dump\n");
            return 1;
        }
        return identify(argv[2]);
    }

    if (!command.empty() && command[0] == '-') {
        print_usage(argv[0]);
        return 1;
    }

    std::fprintf(stderr,
                 "This build cannot run the game. Configure with\n"
                 "  -DHH_WITH_RUNTIME=ON -DHH_WITH_RECOMPILED=ON\n");
    return 1;
}
