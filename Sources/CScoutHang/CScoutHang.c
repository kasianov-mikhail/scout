//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

#include "CScoutHang.h"

#include <stdatomic.h>
#include <string.h>
#include <sys/ucontext.h>

#if defined(__arm64__) || defined(__aarch64__)

uint64_t scout_arm_thread_state64_pc(arm_thread_state64_t state) {
    return (uint64_t)arm_thread_state64_get_pc(state);
}

uint64_t scout_arm_thread_state64_fp(arm_thread_state64_t state) {
    return (uint64_t)arm_thread_state64_get_fp(state);
}

#endif

#define SCOUT_CRASH_MAX_SIGNALS 8

static struct {
    int sig;
    struct sigaction action;
} scout_previous_actions[SCOUT_CRASH_MAX_SIGNALS];

static int scout_previous_count = 0;
static atomic_flag scout_crash_claimed = ATOMIC_FLAG_INIT;

bool scout_crash_install(const int *signals, int count, scout_crash_handler handler) {
    if (count > SCOUT_CRASH_MAX_SIGNALS) {
        return false;
    }

    for (int i = 0; i < count; i++) {
        struct sigaction action;
        memset(&action, 0, sizeof(action));
        action.sa_sigaction = handler;
        action.sa_flags = SA_SIGINFO;
        sigemptyset(&action.sa_mask);

        scout_previous_actions[scout_previous_count].sig = signals[i];
        if (sigaction(signals[i], &action, &scout_previous_actions[scout_previous_count].action) == 0) {
            scout_previous_count++;
        }
    }

    return true;
}

void scout_crash_restore(int sig) {
    for (int i = 0; i < scout_previous_count; i++) {
        if (scout_previous_actions[i].sig == sig) {
            sigaction(sig, &scout_previous_actions[i].action, NULL);
            return;
        }
    }
    signal(sig, SIG_DFL);
}

bool scout_crash_claim(void) {
    return !atomic_flag_test_and_set(&scout_crash_claimed);
}

uint64_t scout_image_text_size(const struct mach_header *header) {
    if (header->magic != MH_MAGIC_64) {
        return 0;
    }

    const struct mach_header_64 *header64 = (const struct mach_header_64 *)header;
    const struct load_command *command = (const struct load_command *)(header64 + 1);

    for (uint32_t i = 0; i < header64->ncmds; i++) {
        if (command->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *segment = (const struct segment_command_64 *)command;
            if (strcmp(segment->segname, SEG_TEXT) == 0) {
                return segment->vmsize;
            }
        }
        command = (const struct load_command *)((const uint8_t *)command + command->cmdsize);
    }

    return 0;
}

void scout_crash_registers(void *context, uint64_t *pc, uint64_t *fp) {
    *pc = 0;
    *fp = 0;

    if (context == NULL) {
        return;
    }

    ucontext_t *ucontext = (ucontext_t *)context;
    mcontext_t mcontext = ucontext->uc_mcontext;
    if (mcontext == NULL) {
        return;
    }

#if defined(__arm64__) || defined(__aarch64__)
    *pc = (uint64_t)arm_thread_state64_get_pc(mcontext->__ss);
    *fp = (uint64_t)arm_thread_state64_get_fp(mcontext->__ss);
#elif defined(__x86_64__)
    *pc = (uint64_t)mcontext->__ss.__rip;
    *fp = (uint64_t)mcontext->__ss.__rbp;
#endif
}
