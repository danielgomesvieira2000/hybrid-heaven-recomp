// The Controller Pak's 32 KiB of storage, and its file on disk.
//
// This header owns the bytes and their persistence, and nothing else. The
// joybus wire format -- the PIF frame layout, the address and data CRCs, which
// block a transaction is asking for -- lives in src/si_pak.cpp, and the
// filesystem written into those bytes is the cartridge's own libultra PFS,
// recompiled from the ROM. Three layers, and this is the bottom one.
//
// The division matters for a practical reason: because the game's own PFS code
// writes the image, what ends up in the file is a real Controller Pak image and
// not an approximation of one. It can be opened by anything else that reads
// them.

#ifndef HH_CONTROLLER_PAK_H
#define HH_CONTROLLER_PAK_H

#include <cstdint>
#include <filesystem>

namespace hh::pak {

// A Controller Pak is 32 KiB: one bank of 128 pages of 256 bytes. Transactions
// address it in 32-byte blocks, which is the joybus payload size.
inline constexpr int kPakSize = 0x8000;
inline constexpr int kBlockSize = 32;
inline constexpr int kBlockCount = kPakSize / kBlockSize;

// Where the .pak files live. Call once, before the game starts, with the same
// directory the rest of the port's configuration uses. Until this is called the
// store has nowhere to persist to and reads come back as a formatted-empty pak
// that is never written out.
void set_storage_directory(const std::filesystem::path& dir);

// Read or write one 32-byte block of the pak in `port`. The file is loaded on
// first touch, and created -- as a valid formatted-empty pak -- if absent.
// Returns false only for an out-of-range port or block.
bool read_block(int port, int block, uint8_t out[kBlockSize]);
bool write_block(int port, int block, const uint8_t in[kBlockSize]);

// Persist every pak modified since the last flush. Cheap and silent when
// nothing has changed, so it is safe to call on a timer; call it from the main
// loop rather than from the game thread, and once more on the way out.
void flush();

// Whether a Controller Pak is presented in `port` at all. Only port 1 has one
// for now (the store, format and joybus layers come from Rayman 2: Recompiled;
// which ports Hybrid Heaven's two players save to is settled in phase 05/06).
bool present(int port);

} // namespace hh::pak

#endif // HH_CONTROLLER_PAK_H
