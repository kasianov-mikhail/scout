//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#ifndef SCOUT_C_SCOUT_HANG_H
#define SCOUT_C_SCOUT_HANG_H

#include <mach/mach.h>
#include <stdint.h>

// arm_thread_state64_get_pc/get_fp are ptrauth-stripping macros, which the
// Swift Clang importer can't bridge — these C functions expose them as
// plain symbols Swift can call.
#if defined(__arm64__) || defined(__aarch64__)
uint64_t scout_arm_thread_state64_pc(arm_thread_state64_t state);
uint64_t scout_arm_thread_state64_fp(arm_thread_state64_t state);
#endif

#endif
