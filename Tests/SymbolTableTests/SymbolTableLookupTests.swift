//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import SymbolTable

@Suite("SymbolTable lookup")
struct SymbolTableLookupTests {
    let table = SymbolTable.sample

    @Test("A frame inside a plain function gets its name and line")
    func plainFunction() {
        #expect(table.frames(offset: 0x2010) == [SymbolTable.Frame(name: "CartView.body.getter", file: "CartView.swift", line: 47)])
    }

    @Test("Inlined calls unwind innermost first, each at its call site")
    func inlineChain() {
        #expect(
            table.frames(offset: 0x1018) == [
                SymbolTable.Frame(name: "Price.rounded()", file: "Price.swift", line: 30),
                SymbolTable.Frame(name: "Price.multiplied(by:)", file: "Price.swift", line: 21),
                SymbolTable.Frame(name: "CartViewModel.applyDiscount(_:)", file: "CartViewModel.swift", line: 84),
            ]
        )
    }

    @Test("Outside the inlined range only the function remains")
    func outsideInline() {
        #expect(table.frames(offset: 0x1040) == [SymbolTable.Frame(name: "CartViewModel.applyDiscount(_:)", file: "CartViewModel.swift", line: 90)])
    }

    @Test("An offset between or past functions has no frames")
    func noFunction() {
        #expect(table.frames(offset: 0x0FFF).isEmpty)
        #expect(table.frames(offset: 0x1F00).isEmpty)
        #expect(table.frames(offset: 0x9000).isEmpty)
    }

    @Test("An offset after the end of a line sequence has no location")
    func endOfSequence() {
        #expect(table.frames(offset: 0x2090) == [SymbolTable.Frame(name: "CartView.body.getter", location: nil)])
    }

    @Test("Unsorted input is sorted before lookup")
    func unsortedInput() {
        let shuffled = SymbolTable(
            uuid: table.uuid,
            functions: table.functions.reversed(),
            lines: table.lines.reversed(),
            inlines: table.inlines.reversed()
        )

        #expect(shuffled == table)
        #expect(shuffled.frames(offset: 0x1018) == table.frames(offset: 0x1018))
    }
}

extension SymbolTable.Frame {
    fileprivate init(name: String, file: String, line: Int) {
        self.init(name: name, location: SymbolTable.Location(file: file, line: line))
    }
}
