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
@testable import ScoutUI

@Suite("IncidentStack")
struct IncidentStackTests {
    @Test("Symbolicated frames carry their location and the rest keep the fallback text")
    func symbolicated() {
        let stack = IncidentStack(detail: .sample, fallback: Crash.sample.stackTrace)

        #expect(stack.rows.count == 13)
        #expect(stack.rows[3].symbol == "FeedViewController.row(at:)")
        #expect(stack.rows[3].location?.text == "FeedViewController.swift:142")
        #expect(stack.rows[5].symbol == "-[UITableView _createPreparedCellForGlobalRow:withIndexPath:]")
        #expect(stack.culprit?.id == 3)
        #expect(stack.caller?.id == 4)
        #expect(stack.caller?.bareSymbol == "tableView(_:cellForRowAt:)")
        #expect(stack.isSymbolicated)
    }

    @Test("A raw stack gives one row per line")
    func fallback() {
        let stack = IncidentStack(
            detail: nil,
            fallback: [
                "0   CoreFoundation   0x0 __exceptionPreprocess + 164",
                "1   MyApp            0x0 + 4096",
            ]
        )

        #expect(stack.rows.map(\.id) == [0, 1])
        #expect(stack.rows[0].image == "CoreFoundation")
        #expect(stack.rows[0].symbol == "__exceptionPreprocess")
        #expect(stack.rows[1].symbol == "+ 4096")
        #expect(stack.culprit == nil)
        #expect(!stack.isSymbolicated)
    }

    @Test("A frame without symbols falls back to its raw line")
    func missingSymbol() {
        let stack = IncidentStack(detail: .resourceSample, fallback: ResourceException.sample.stackTrace)

        #expect(stack.rows[2].symbol == "-[UIGraphicsImageRenderer imageWithActions:]")
        #expect(stack.rows[2].location == nil)
        #expect(stack.culprit?.symbol == "ImageCache.resize(_:to:)")
        #expect(stack.caller?.symbol == "ImageCache.resizeAll(_:)")
    }
}
