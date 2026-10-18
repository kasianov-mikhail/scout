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

@testable import Scout
@testable import ScoutUI

@Suite("SymbolicatedStack")
struct SymbolicatedStackTests {
    let app = UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E")!

    var backtrace: Backtrace {
        Backtrace(
            images: [Backtrace.Image(name: "MyApp", uuid: app), Backtrace.Image(name: "UIKitCore", uuid: UUID())],
            threads: [
                Backtrace.Thread(
                    attributed: true,
                    frames: [
                        Backtrace.Frame(image: 0, offset: 0x10),
                        Backtrace.Frame(image: 1, offset: 0x500),
                        Backtrace.Frame(image: 0, offset: 0x21),
                    ]
                )
            ]
        )
    }

    var table: SymbolTable {
        SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "CartViewModel.applyDiscount(_:)")],
            lines: [
                SymbolTable.Line(address: 0x10, location: SymbolTable.Location(file: "CartViewModel.swift", line: 84)),
                SymbolTable.Line(address: 0x20, location: SymbolTable.Location(file: "CartViewModel.swift", line: 90)),
            ],
            inlines: []
        )
    }

    @Test("Frames with a table read as functions and lines, the rest keep the device's text")
    func lines() throws {
        let fallback = ["0   MyApp   + 0x10", "1   UIKitCore   0x500 -[UIApplication sendAction:] + 8", "2   MyApp   + 0x21"]

        let stack = try #require(SymbolicatedStack(detail: BacktraceDetail(backtrace: backtrace, tables: [app: table]), fallback: fallback))

        #expect(
            stack.lines == [
                "0   MyApp   CartViewModel.applyDiscount(_:) (CartViewModel.swift:84)",
                "1   UIKitCore   0x500 -[UIApplication sendAction:] + 8",
                "2   MyApp   CartViewModel.applyDiscount(_:) (CartViewModel.swift:90)",
            ]
        )
    }

    @Test("Without any table there is nothing to symbolicate")
    func noTables() {
        #expect(SymbolicatedStack(detail: BacktraceDetail(backtrace: backtrace, tables: [:]), fallback: []) == nil)
    }
}
