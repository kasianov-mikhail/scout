//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import DWARF

@Suite("RangeList")
struct RangeListTests {
    @Test("DWARF 5 range lists resolve every entry kind against the current base")
    func rangeLists() throws {
        var bytes: [UInt8] = []
        bytes += [4, 0x10, 0x20]
        bytes += [5] + encoded(value: 0x2000)
        bytes += [4, 0x00, 0x08]
        bytes += [3, 0x01, 0x04]
        bytes += [2, 0x00, 0x01]
        bytes += [6] + encoded(value: 0x5000) + encoded(value: 0x5010)
        bytes += [7] + encoded(value: 0x6000) + [0x02]
        bytes += [1, 0x01, 4, 0x00, 0x04]
        bytes += [0]

        let list = try RangeList(section: bytes[...], offset: 0, base: 0x1000, addressSize: 8) { index in
            [0x3000, 0x4000][Int(index)]
        }

        #expect(
            list.ranges == [
                0x1010..<0x1020,
                0x2000..<0x2008,
                0x4000..<0x4004,
                0x3000..<0x4000,
                0x5000..<0x5010,
                0x6000..<0x6002,
                0x4000..<0x4004,
            ]
        )
    }

    @Test("DWARF 4 ranges follow base address selections")
    func legacyRanges() throws {
        var bytes: [UInt8] = []
        bytes += encoded(value: 0x10) + encoded(value: 0x20)
        bytes += encoded(value: UInt64.max) + encoded(value: 0x9000)
        bytes += encoded(value: 0x04) + encoded(value: 0x08)
        bytes += encoded(value: 0) + encoded(value: 0)

        let list = try RangeList(legacySection: bytes[...], offset: 0, base: 0x1000, addressSize: 8)

        #expect(list.ranges == [0x1010..<0x1020, 0x9004..<0x9008])
    }

    @Test("A range that ends before it starts is rejected")
    func invertedRange() {
        let bytes: [UInt8] = [6] + encoded(value: 0x20) + encoded(value: 0x10) + [0]

        #expect(throws: MalformedDWARFError.self) {
            try RangeList(section: bytes[...], offset: 0, base: 0, addressSize: 8) { _ in 0 }
        }
    }

    private func encoded(value: UInt64) -> [UInt8] {
        withUnsafeBytes(of: value.littleEndian, Array.init)
    }
}
