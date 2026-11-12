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

@Suite("BacktraceDetail")
struct BacktraceDetailTests {
    let app = UUID(uuidString: "4F2A1C9E-7B3D-3A11-8E5C-2D9F6B1AC19E")!

    var backtrace: Backtrace {
        Backtrace(
            images: [Backtrace.Image(name: "UIKitCore", uuid: UUID()), Backtrace.Image(name: "MyApp", uuid: app)],
            threads: [
                Backtrace.Thread(attributed: false, frames: [Backtrace.Frame(image: 1, offset: 0x90)]),
                Backtrace.Thread(
                    attributed: true,
                    frames: [Backtrace.Frame(image: 0, offset: 0x500), Backtrace.Frame(image: 1, offset: 0x11)]
                ),
            ]
        )
    }

    var table: SymbolTable {
        SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "CartViewModel.applyDiscount(_:)")],
            lines: [SymbolTable.Line(address: 0, location: SymbolTable.Location(file: "CartViewModel.swift", line: 84))],
            inlines: [
                SymbolTable.Inline(
                    start: 0,
                    end: 0x40,
                    depth: 1,
                    name: "Price.rounded()",
                    call: SymbolTable.Location(file: "CartViewModel.swift", line: 84)
                )
            ]
        )
    }

    @Test("The key names the first frame with symbols by its outermost function")
    func groupKey() {
        let detail = BacktraceDetail(backtrace: backtrace, tables: [app: table])

        #expect(detail.groupKey == "MyApp|CartViewModel.applyDiscount(_:)")
    }

    @Test("Return addresses look up the call instruction before them")
    func returnAddress() {
        let frames = BacktraceDetail(backtrace: backtrace, tables: [app: table]).attributedFrames

        #expect(frames.map(\.index) == [0, 1])
        #expect(frames[0].symbols.isEmpty)
        #expect(frames[1].symbols.map(\.name) == ["Price.rounded()", "CartViewModel.applyDiscount(_:)"])
    }

    @Test("Without tables there is no key")
    func noTables() {
        #expect(BacktraceDetail(backtrace: backtrace, tables: [:]).groupKey == nil)
    }
}
