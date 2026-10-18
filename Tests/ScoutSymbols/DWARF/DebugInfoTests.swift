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

@Suite("DebugInfo")
struct DebugInfoTests {
    @Test("Subprograms become functions with their address ranges", arguments: ["dwarf4", "dwarf5"])
    func functions(name: String) throws {
        let info = try DebugInfo(image: MachOImage(data: Data(fixture: name)))

        #expect(
            info.functions == [
                SymbolTable.Function(start: 0x328, end: 0x390, name: "sum_of_squares"),
                SymbolTable.Function(start: 0x390, end: 0x3AC, name: "square"),
                SymbolTable.Function(start: 0x3AC, end: 0x3D0, name: "main"),
            ]
        )
        #expect(info.inlines.isEmpty)
    }

    @Test("Nested inlined calls keep their depth, name, and call site", arguments: ["inline4", "inline5"])
    func inlines(name: String) throws {
        let info = try DebugInfo(image: MachOImage(data: Data(fixture: name)))

        #expect(
            info.functions == [
                SymbolTable.Function(start: 0x328, end: 0x338, name: "compute"),
                SymbolTable.Function(start: 0x338, end: 0x340, name: "main"),
            ]
        )
        #expect(
            info.inlines == [
                SymbolTable.Inline(start: 0x328, end: 0x330, depth: 1, name: "sum_of_squares", call: SymbolTable.Location(file: "inline.c", line: 10)),
                SymbolTable.Inline(start: 0x328, end: 0x32C, depth: 2, name: "square", call: SymbolTable.Location(file: "inline.c", line: 6)),
            ]
        )
    }

    @Test("A table built from the dSYM unwinds frames like atos -i", arguments: ["inline4", "inline5"])
    func matchesAtos(name: String) throws {
        let table = try SymbolTable(image: MachOImage(data: Data(fixture: name)))

        #expect(table.frames(offset: 0x328).map(\.text) == ["square (inline.c:2)", "sum_of_squares (inline.c:6)", "compute (inline.c:10)"])
        #expect(table.frames(offset: 0x32C).map(\.text) == ["sum_of_squares (inline.c:6)", "compute (inline.c:10)"])
        #expect(table.frames(offset: 0x334).map(\.text) == ["compute (inline.c:10)"])
        #expect(table.frames(offset: 0x33C).map(\.text) == ["main (inline.c:14)"])
    }
}

extension SymbolTable.Frame {
    fileprivate var text: String {
        "\(name) (\(location?.file ?? "?"):\(location?.line ?? 0))"
    }
}
