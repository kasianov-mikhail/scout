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
    @Test("Abnormal reasons come largest first, with their share per thousand exits")
    func abnormalShares() {
        let summary = ExitSummary(counts: [.normal: 990, .badAccess: 2, .watchdog: 6, .memoryLimit: 2])

        #expect(summary.abnormal.map(\.reason) == [.watchdog, .badAccess, .memoryLimit])
        #expect(summary.abnormal.map(\.perMille) == [6, 2, 2])
        #expect(summary.abnormal.first?.formatted == "6.0 ‰")
        #expect(summary.abnormalPerMille == 10)
    }

    @Test("A version without exit data has no abnormal exits")
    func noExits() {
        #expect(ExitSummary(counts: [:]).total == 0)
        #expect(ExitSummary(counts: [:]).abnormal.isEmpty)
    }
}
