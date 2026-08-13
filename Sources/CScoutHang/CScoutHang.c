//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

#include "CScoutHang.h"

#if defined(__arm64__) || defined(__aarch64__)

uint64_t scout_arm_thread_state64_pc(arm_thread_state64_t state) {
    return (uint64_t)arm_thread_state64_get_pc(state);
}

uint64_t scout_arm_thread_state64_fp(arm_thread_state64_t state) {
    return (uint64_t)arm_thread_state64_get_fp(state);
}

#endif
