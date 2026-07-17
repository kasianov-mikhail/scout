//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CScoutHang
import Foundation
import MachO

/// Captures the main thread's call stack from a different thread by briefly
/// suspending it and manually walking its frame-pointer chain.
///
/// This is only safe because the suspend window is short and every memory
/// read goes through `mach_vm_read_overwrite`, which fails gracefully on an
/// invalid address instead of trapping.
///
enum MainThreadBacktrace {
    static let maximumFrameCount = 64

    static func capture() -> [String] {
        guard let mainThread = mainMachThread() else { return [] }

        // Only raw return addresses are collected while the main thread is
        // suspended — no malloc, no dyld lock. If the thread is suspended
        // mid-hang while holding one of those locks, symbolicating here would
        // deadlock this thread forever. So resume first, then symbolicate.
        var buffer = [UInt64](repeating: 0, count: maximumFrameCount)
        let count = buffer.withUnsafeMutableBufferPointer { captureAddresses(of: mainThread, into: $0) }
        guard count > 0 else { return [] }

        return buffer.prefix(count).enumerated().map(symbolicate)
    }

    private static func captureAddresses(of thread: thread_t, into buffer: UnsafeMutableBufferPointer<UInt64>) -> Int {
        guard thread_suspend(thread) == KERN_SUCCESS else { return 0 }
        defer { thread_resume(thread) }

        guard let (pc, initialFP) = registerState(of: thread) else { return 0 }

        buffer[0] = pc
        var count = 1
        var fp = initialFP

        while count < buffer.count {
            guard fp != 0, let frame = readFrame(at: fp), frame.returnAddress != 0 else { break }
            buffer[count] = frame.returnAddress
            count += 1
            fp = frame.previousFP
        }

        return count
    }

    // task_threads returns threads in creation order and the main thread is
    // always created first — there's no documented API to ask for it directly.
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

        return threadCount > 0 ? threadList[0] : nil
    }

    private struct Frame {
        let previousFP: UInt64
        let returnAddress: UInt64
    }

    private static func readFrame(at fp: UInt64) -> Frame? {
        var pair: (previousFP: UInt64, returnAddress: UInt64) = (0, 0)
        var readCount: vm_size_t = 0

        let result = withUnsafeMutableBytes(of: &pair) { rawBuffer in
            vm_read_overwrite(
                mach_task_self_,
                vm_address_t(fp),
                vm_size_t(MemoryLayout<UInt64>.size * 2),
                vm_address_t(UInt(bitPattern: rawBuffer.baseAddress)),
                &readCount
            )
        }

        guard result == KERN_SUCCESS, readCount == vm_size_t(MemoryLayout<UInt64>.size * 2) else {
            return nil
        }

        return Frame(previousFP: pair.previousFP, returnAddress: pair.returnAddress)
    }

    private static func symbolicate(index: Int, address: UInt64) -> String {
        var info = Dl_info()

        guard let pointer = UnsafeRawPointer(bitPattern: UInt(address)), dladdr(pointer, &info) != 0 else {
            return "\(index)   ???                  0x\(String(address, radix: 16))"
        }

        let image = info.dli_fname.map { String(cString: $0).components(separatedBy: "/").last ?? "???" } ?? "???"
        let symbol = info.dli_sname.map { String(cString: $0) } ?? "0x\(String(address, radix: 16))"
        let offset = info.dli_saddr.map { address - UInt64(UInt(bitPattern: $0)) } ?? 0

        return "\(index)   \(image)   0x\(String(address, radix: 16)) \(symbol) + \(offset)"
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

        guard result == KERN_SUCCESS else { return nil }
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

        guard result == KERN_SUCCESS else { return nil }
        return (state.__rip, state.__rbp)
    }
#else
    private func registerState(of thread: thread_t) -> (pc: UInt64, fp: UInt64)? {
        nil
    }
#endif
