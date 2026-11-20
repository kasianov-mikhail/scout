//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("EventPendingSummary")
struct EventPendingSummaryTests {
    @Test("Groups the counts by severity, most severe first")
    func groupsBySeverity() {
        let summary = EventPendingSummary(
            counts: [.critical: 1, .error: 2, .warning: 1, .notice: 4],
            limit: 4
        )

        #expect(summary.groups.map(\.level) == [.critical, .error, .warning, .notice])
        #expect(summary.groups.map(\.count) == [1, 2, 1, 4])
        #expect(summary.total == 8)
    }

    @Test("Cuts the quietest levels past the limit")
    func cutsQuietestLevels() {
        let summary = EventPendingSummary(
            counts: [.critical: 1, .trace: 1, .debug: 1, .info: 1, .notice: 1, .warning: 1],
            limit: 4
        )

        #expect(summary.groups.map(\.level) == [.critical, .warning, .notice, .info])
        #expect(summary.total == 6)
    }

    @Test("No counts leave no groups")
    func noCounts() {
        let summary = EventPendingSummary(counts: [:], limit: 4)

        #expect(summary.groups.isEmpty)
        #expect(summary.total == 0)
        #expect(summary.isEmpty)
    }
}
