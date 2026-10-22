//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CScoutHang
import Foundation
import MachO

enum MainThreadBacktrace {
    static func capture() -> [UInt64] {
        guard let mainThread = mainMachThread() else {
            return []
        }
        defer { mach_port_deallocate(mach_task_self_, mainThread) }

        var buffer = [UInt64](repeating: 0, count: StackWalker.maximumFrameCount)
        let count = buffer.withUnsafeMutableBufferPointer { captureAddresses(of: mainThread, into: $0) }
        return Array(buffer.prefix(count))
    }

    private static func captureAddresses(of thread: thread_t, into buffer: UnsafeMutableBufferPointer<UInt64>) -> Int {
        guard thread_suspend(thread) == KERN_SUCCESS else {
            return 0
        }
        defer { thread_resume(thread) }

        guard let (pc, fp) = registerState(of: thread) else {
            return 0
        }

        return StackWalker.walk(pc: pc, fp: fp, into: buffer)
    }

    private static func mainMachThread() -> thread_t? {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS, let threadList else {
            return nil
        }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: threadList)),
                vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride)
            )
        }

        let threads = UnsafeBufferPointer(start: threadList, count: Int(threadCount))
        for thread in threads.dropFirst() {
            mach_port_deallocate(mach_task_self_, thread)
        }
        return threads.first
    }
}

#if arch(arm64)
    private func registerState(of thread: thread_t) -> (pc: UInt64, fp: UInt64)? {
        var state = arm_thread_state64_t()
        var count = mach_msg_type_number_t(MemoryLayout<arm_thread_state64_t>.size / MemoryLayout<natural_t>.size)

        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: natural_t.self, capacity: Int(count)) { rebound in
                thread_get_state(thread, thread_state_flavor_t(ARM_THREAD_STATE64), rebound, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }
        return (scout_arm_thread_state64_pc(state), scout_arm_thread_state64_fp(state))
    }
#elseif arch(x86_64)
    private func registerState(of thread: thread_t) -> (pc: UInt64, fp: UInt64)? {
        var state = x86_thread_state64_t()
        var count = mach_msg_type_number_t(MemoryLayout<x86_thread_state64_t>.size / MemoryLayout<natural_t>.size)

        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: natural_t.self, capacity: Int(count)) { rebound in
                thread_get_state(thread, thread_state_flavor_t(x86_THREAD_STATE64), rebound, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return nil
        }
        return (state.__rip, state.__rbp)
    }
#else
    private func registerState(of thread: thread_t) -> (pc: UInt64, fp: UInt64)? {
        nil
    }
#endif
