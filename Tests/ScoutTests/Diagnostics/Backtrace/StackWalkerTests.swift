//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

@Suite("StackWalker")
struct StackWalkerTests {
    @Test("walks a crafted frame-pointer chain")
    func walksCraftedChain() {
        var storage = [UInt64](repeating: 0, count: 4)

        let (count, frames) = storage.withUnsafeMutableBufferPointer { chain in
            let base = UInt64(UInt(bitPattern: chain.baseAddress))

            chain[0] = base + 16
            chain[1] = 0x1001
            chain[2] = 0
            chain[3] = 0x1002

            var buffer = [UInt64](repeating: 0, count: 8)
            let count = buffer.withUnsafeMutableBufferPointer {
                StackWalker.walk(pc: 0xABC0, fp: base, into: $0)
            }
            return (count, buffer)
        }

        #expect(count == 3)
        #expect(frames[0] == 0xABC0)
        #expect(frames[1] == 0x1001)
        #expect(frames[2] == 0x1002)
    }

    @Test("a zero program counter produces no frames")
    func zeroProgramCounter() {
        var buffer = [UInt64](repeating: 0, count: 8)
        let count = buffer.withUnsafeMutableBufferPointer {
            StackWalker.walk(pc: 0, fp: 0x1000, into: $0)
        }

        #expect(count == 0)
    }

    @Test("a zero frame pointer keeps the program counter alone")
    func zeroFramePointer() {
        var buffer = [UInt64](repeating: 0, count: 8)
        let count = buffer.withUnsafeMutableBufferPointer {
            StackWalker.walk(pc: 0xABC0, fp: 0, into: $0)
        }

        #expect(count == 1)
        #expect(buffer[0] == 0xABC0)
    }

    @Test("the walk stops at the buffer's capacity")
    func walkStopsAtCapacity() {
        var storage = [UInt64](repeating: 0, count: 2)

        let count = storage.withUnsafeMutableBufferPointer { chain in
            let base = UInt64(UInt(bitPattern: chain.baseAddress))

            // The frame links back to itself: an unbounded walk would never end.
            chain[0] = base
            chain[1] = 0x1001

            var buffer = [UInt64](repeating: 0, count: 8)
            return buffer.withUnsafeMutableBufferPointer {
                StackWalker.walk(pc: 0xABC0, fp: base, into: $0)
            }
        }

        #expect(count == 8)
    }
}
