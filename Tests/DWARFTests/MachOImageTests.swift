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

@Suite("MachOImage")
struct MachOImageTests {
    @Test("A dSYM reports its UUID, text address, and DWARF sections")
    func thinImage() throws {
        let image = try MachOImage(data: Data(fixture: "dwarf5"))

        #expect(image.uuid == UUID.fixture)
        #expect(image.textAddress == 0x1_0000_0000)
        #expect(!image.section(name: "__debug_line").isEmpty)
        #expect(image.section(name: "__debug_missing").isEmpty)
    }

    @Test("A universal file yields its arm64 slice")
    func universalImage() throws {
        let thin = try Data(fixture: "dwarf5")
        var fat = Data()
        for value: UInt32 in [0xCAFE_BABE, 1, 0x0100_000C, 0, 4096, UInt32(thin.count), 14] {
            withUnsafeBytes(of: value.bigEndian) { fat += $0 }
        }
        fat += Data(count: 4096 - fat.count) + thin

        let image = try MachOImage(data: fat)

        #expect(image.uuid == UUID.fixture)
        #expect(image.section(name: "__debug_line") == (try MachOImage(data: thin)).section(name: "__debug_line"))
    }

    @Test("Data that is not a Mach-O file is rejected")
    func foreignData() {
        #expect(throws: MalformedDWARFError.self) { try MachOImage(data: Data(repeating: 7, count: 64)) }
        #expect(throws: MalformedDWARFError.self) { try MachOImage(data: Data()) }
    }
}
