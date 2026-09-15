# Phase 04 findings — boot bring-up

The working record, wrong turns included; not rewritten later.

**Gate:** in progress.
- **Reached so far:** the KCEO logo, the Expansion Pak screen, the night-city intro cinematic,
  the **title screen ("PRESS START BUTTON")** and the attract loop's TV-static scene. All render
  recognisably, at a steady 30 display lists per second, with music (peak amplitude 20–31k),
  in a 90 s unattended run.
- **Still to show:** New Game → opening cutscene → first controllable scene, driven by scripted
  input; no lookup miss in 10 minutes of scripted play; the D7 Expansion Pak comparison.

Reproduce:

```
powershell -ExecutionPolicy Bypass -File tools/shoot_run.ps1 -Count 15 -Interval 6 -Delay 4 -OutDir <dir>
   with HH_DEBUG_LOADS=1 HH_FRAME_STATS=1 HH_AUDIO_STATS=1 set in the shell
```

## Answer

Three faults stood between the phase-03 harness and the title screen. Each matches a pattern the
playbook already records:

1. **An unnamed libultra routine posted to a queue nothing reads.** The file loader's ROM reads go
   through `osEPiStartDma` (`0x800304F0`). The game's own copy sent to the PI manager command queue,
   but the manager is the runtime's, so every game thread parked in `osRecvMesg` right after file 8
   loaded. Rayman 2 hit the same with `osPiStartDma` (playbook 05). Fixed by naming it.
2. **The Konami audio manager's frame-size clamp uses an unsigned compare.** Hardware keeps
   `osAiGetLength` under a frame, so the difference never goes negative there. With the host queue
   deeper, it goes negative, passes the clamp, and `osAiSetNextBuffer` gets −0x1000 bytes. Fixed with
   a one-instruction patch, the same one Goemon64Recomp applies to Mystical Ninja's copy of this code.
3. **The main loop's frame limiter busy-waits on `osGetTime`.** Under ultramodern's cooperative
   scheduler it starves the other game threads. The frame rate fell to 14 lists/s, then presentation
   stopped about 30 s in. Fixed with a 1 ms yield hook per iteration, taken from Rayman 2 (playbook 05).

One port-side value also had to change. The private audio command-list copy moved from `0x80F00000`
to `0x807F0000`, because the runtime fork bounds RSP DMAs to 8 MB.

## Measurements

### Run 1 (phase-03 build): parked after file 8

| What | Result |
|---|---|
| `HH_SAMPLE=1` thread sampler | 282 rounds: 1 sample executing our code, 13,831 parked in system waits. Stack return addresses symbolised to `osRecvMesg_recomp` and ultramodern semaphore waits |
| File loads (`HH_DEBUG_LOADS`) | file 8 only |
| Display lists | 0 |
| ROM read path | `file_load` → `func_80001FE8` → `func_80001F30`. It fills an `OSIoMesg` at `0x8005CD80` (reply queue `0x8005C268`), calls `func_800304F0(handle, mb, direction)`, then `osRecvMesg(reply, NULL, BLOCK)` |
| `func_800304F0` body | libultra 2.0I `osEPiStartDma` exactly: −1 unless the manager is active; `mb->piHandle`; type 0xF/0x10; `osJamMesg` on high priority, else `osSendMesg`, to `osPiGetCmdQueue()` |

### Run 2 (`osEPiStartDma` named): first picture, then a crash

| What | Result |
|---|---|
| First display list | ucode `0x800351A0` (F3DEX2 text), data `0x8004D4F0` (its data, holding the "RSP Gfx ucode F3DEX fifo 2.06" string at ROM `0x4E228`, so the string *is* the graphics microcode's data), DL `0x800692B0` |
| RSP | `microcode DMA from RDRAM 0x00F00000..0x00F00140 runs past the 8 MB of RDRAM an N64 has`, on every audio task |
| Crash | `ACCESS_VIOLATION` in `queue_samples` reading `rdram + 0x20000002`, from `osAiSetNextBuffer_recomp` ← `func_8001FD14` (audio manager) ← `func_8001FBA8` (audio thread) |
| `HH_TRACE_AI=1` | `osAiSetNextBuffer(0x800C9A40, 0xF80)` … `(0x800C8A50, 0xB40)` … `(0x800C8A50, 0xFFFFFFFFFFFFF000)` then the crash. The **size** went negative; the pointer was valid |
| Size computation (`0x8001FD54–0x8001FD9C`) | `frameSamples = (target − osAiGetLength()>>2 + 0x100) & 0xFFF0`, raised to the minimum with `sltu $at, $a3, $v1` at `0x8001FD8C`. A negative value compared unsigned is huge, so the clamp never fires |

### Run 3 (clamp patched, scratch moved): stall at ~30 s

| What | Result |
|---|---|
| `HH_FRAME_STATS=1` | 60 lists/s during the logos. After the file-24 heap load (below), **14 lists/s**, and screen updates stop at t≈31 s while audio buffers keep flowing |
| Audio | 60 buffers/s, queue 36–74 ms, **peak amplitude 0**: silent |
| Sampler | the main game thread executing `func_80001454` around `osGetTime`, `__ull_div` and `duration_to_ticks` |
| `func_80001454` `0x80001A88–0x80001B18` | `target = func_80133AA0(); do { elapsed = (osGetTime() − D_80037760) × 64 / 3000 / D_8004B908 } while (elapsed < target)`: a frame limiter that polls the clock and never yields |
| `tools/find_spin_loops.py` | 0 candidates. It only reports call-free loops, and this one calls `osGetTime` |

### Run 4 (yield hook): title screen

| t (s) | Display lists / 60 updates | On screen |
|---|---|---|
| 2–8 | 58–60 | KCEO "presents" logo |
| 9–33 | 29–30 | Expansion Pak screen ("Expansion Pak Enhanced") |
| 34 | 27 | night-city cinematic; audio peaks begin (20,624) |
| 52 | 29 | **HYBRID HEAVEN title, PRESS START BUTTON** |
| 88 | — | TV static with "VOL. IIIII" (attract loop) |

### File loads, as the game does them

| Caller | What it does | Files seen |
|---|---|---|
| `0x80004484` | `file_load(id, align8(D_801BBC10))`: into an arena pointer | 55 at `0x803837E0` |
| `0x800044BC` | `file_load(id, align8(D_80089470))`, then stores the end back (a bump allocator starting at `0x801BF1A0`) | 24 at `0x801BF1A0` |
| `0x800045E8` | `dest = func_8001F290(vram span)` (heap allocation), `file_load(id, dest)`, then `func_80016EAC(id, dest)` records (id → address) in a table (`func_80017384`/`func_800173B8`) | **24 at `0x801FA948`**, not its link address |

The heap load of file 24 is reported ("loaded at 0x801FA948, but its code is linked at 0x801BF1A0");
the wrapper registers the file at its link address anyway. No lookup miss followed in 90 s, so it is
*inferred* that this copy is used as data (a cache), not executed. **Open:** if code ever runs from a
heap copy, the recompiled code (absolute addresses) is wrong there, and the loud warning is where to
start.

## Negative results

- **`HH_TRACE_AI` first showed nothing.** `tools/boot_runs.ps1 -Env "A=1","B=1"` passed both pairs to
  the child PowerShell as one string, so only `HH_DEBUG_LOADS` was set, with value `"1,HH_TRACE_AI=1"`.
  A stack trace then *looked* like a direct `osAiSetNextBuffer_recomp` call bypassing the lookup; it was
  an inlined `LOOKUP_FUNC`. Set variables in the calling shell instead.
- **The thread sampler perturbs audio timing.** With `HH_SAMPLE=1` (every thread suspended 100×/s),
  one run produced a 30,462-command audio task and a crash on a corrupted audio manager pointer. The
  same build without the sampler ran 60 s clean. Treat sampler runs as locating, not as behavioural
  evidence.
- **The `0x80F00000` command-list scratch** came from Pilotwings 64. It is correct on upstream
  N64ModernRuntime, and it breaks on the fork, which clamps RSP DMAs to 8 MB (Rayman 2's fix).

## Inference

- *Inferred:* `0x807F0000–0x80800000` is unused by the game. Nothing in the file table claims it, and
  file 3 ends at `0x80796000`. To re-check if the hi-res mode or a heap grows.
- *Inferred:* the heap copy of file 24 is data use (above).
- *Inferred:* the frame limiter targets 30 fps. Display lists settle at 29–30 per 60 screen updates
  once it can yield.
