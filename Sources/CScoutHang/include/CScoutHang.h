//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

#ifndef SCOUT_C_SCOUT_HANG_H
#define SCOUT_C_SCOUT_HANG_H

#include <mach-o/loader.h>
#include <mach/mach.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>

// arm_thread_state64_get_pc/get_fp are ptrauth-stripping macros, which the
// Swift Clang importer can't bridge — these C functions expose them as
// plain symbols Swift can call.
#if defined(__arm64__) || defined(__aarch64__)
uint64_t scout_arm_thread_state64_pc(arm_thread_state64_t state);
uint64_t scout_arm_thread_state64_fp(arm_thread_state64_t state);
#endif

// Fatal-signal bookkeeping lives in C so the handler touches no Swift
// runtime structures: previous sigactions sit in a fixed static array
// written once at install, and every function here is async-signal-safe.
typedef void (*scout_crash_handler)(int, siginfo_t *_Nullable, void *_Nullable);

void scout_crash_install(const int *_Nonnull signals, int count, scout_crash_handler _Nonnull handler);
void scout_crash_restore(int sig);
bool scout_crash_claim(void);
void scout_crash_registers(void *_Nullable context, uint64_t *_Nonnull pc, uint64_t *_Nonnull fp);

// getsegbynamefromheader_64 has no Swift import — this wraps the __TEXT
// segment size lookup the image table needs.
uint64_t scout_image_text_size(const struct mach_header *_Nonnull header);

#endif
