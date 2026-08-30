//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import MachO

// Walks a frame-pointer chain into a caller-supplied buffer and renders
// addresses into report lines. Both halves are shared by the hang watchdog
// and the fatal-signal handler, so `walk` must stay async-signal-safe: no
// allocation, no locks — every memory read goes through
// `vm_read_overwrite`, which fails gracefully on an invalid address
// instead of trapping.
enum StackWalker {
    static let maximumFrameCount = 64

    static func walk(pc: UInt64, fp: UInt64, into buffer: UnsafeMutableBufferPointer<UInt64>) -> Int {
        guard buffer.count > 0, pc != 0 else {
            return 0
        }

        buffer[0] = pc
        var count = 1
        var fp = fp

        while count < buffer.count {
            guard fp != 0, let frame = readFrame(at: fp), frame.returnAddress != 0 else {
                break
            }
            buffer[count] = frame.returnAddress
            count += 1
            fp = frame.previousFP
        }

        return count
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

    static func unknownFrame(index: Int, address: UInt64) -> String {
        "\(index)   ???                  0x\(String(address, radix: 16))"
    }

    static func symbolicate(index: Int, address: UInt64) -> String {
        var info = Dl_info()

        guard let pointer = UnsafeRawPointer(bitPattern: UInt(address)), dladdr(pointer, &info) != 0 else {
            return unknownFrame(index: index, address: address)
        }

        let image = info.dli_fname.map { String(cString: $0).components(separatedBy: "/").last ?? "???" } ?? "???"
        let symbol = info.dli_sname.map { String(cString: $0) } ?? "0x\(String(address, radix: 16))"
        let offset = info.dli_saddr.map { address - UInt64(UInt(bitPattern: $0)) } ?? 0

        return "\(index)   \(image)   0x\(String(address, radix: 16)) \(symbol) + \(offset)"
    }
}
