//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@Suite("ExitSummary")
struct ExitSummaryTests {
    @Test("Total sums every exit reason")
    func total() {
        let summary = ExitSummary(counts: [.normal: 900, .memoryPressure: 80, .watchdog: 15, .badAccess: 5])

        #expect(summary.total == 1000)
    }

    @Test("Abnormal reasons come largest first, with their share per thousand exits")
    func abnormalShares() {
        let summary = ExitSummary(counts: [.normal: 990, .badAccess: 2, .watchdog: 6, .memoryLimit: 2])

        #expect(summary.abnormal.map(\.reason) == [.watchdog, .badAccess, .memoryLimit])
        #expect(summary.abnormal.map(\.perMille) == [6, 2, 2])
        #expect(summary.abnormal.first?.formatted == "6.0 ‰")
    }

    @Test("A version without exit data has no abnormal shares")
    func noExits() {
        #expect(ExitSummary(counts: [:]).abnormal.isEmpty)
    }
}
