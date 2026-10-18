//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable
import Testing

@testable import DWARF

@Suite("LineTable")
struct LineTableTests {
    @Test("Line programs map offsets to source lines", arguments: ["dwarf4", "dwarf5"])
    func lines(name: String) throws {
        let table = try LineTable(image: MachOImage(data: Data(fixture: name)))

        #expect(
            table.lines == [
                SymbolTable.Line(offset: 0x328, line: 5),
                SymbolTable.Line(offset: 0x338, line: 6),
                SymbolTable.Line(offset: 0x33C, line: 7),
                SymbolTable.Line(offset: 0x358, line: 8),
                SymbolTable.Line(offset: 0x36C, line: 9),
                SymbolTable.Line(offset: 0x370, line: 7),
                SymbolTable.Line(offset: 0x380, line: 10),
                SymbolTable.Line(offset: 0x390, line: 1),
                SymbolTable.Line(offset: 0x398, line: 2),
                SymbolTable.Line(offset: 0x3AC, line: 13),
                SymbolTable.Line(offset: 0x3BC, line: 14),
                SymbolTable.Line(address: 0x3D0, location: nil),
            ]
        )
    }

    @Test("A truncated line section is rejected instead of trapping")
    func truncated() throws {
        let image = try MachOImage(data: Data(fixture: "dwarf5"))
        let section = image.section(name: "__debug_line")
        let strings = StringSections(debugStrings: [], lineStrings: image.section(name: "__debug_line_str"))

        for length in 1..<section.count {
            #expect(throws: MalformedDWARFError.self) {
                try LineTable(section: section.prefix(length), strings: strings, base: image.textAddress)
            }
        }
    }
}

extension SymbolTable.Line {
    fileprivate init(offset: UInt64, line: Int) {
        self.init(address: offset, location: SymbolTable.Location(file: "fixture.c", line: line))
    }
}
