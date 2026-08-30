//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertStatusTests {
    @Test("Detail pairs the current value with the condition")
    func detail() {
        let status = makeStatus(recent: [0.998, 0.9], state: .armed)

        #expect(status.detail == "90.00% — below 99.50%")
    }

    @Test("An empty reading carries no detail")
    func emptyDetail() {
        let status = makeStatus(recent: [], state: .armed)

        #expect(status.detail == nil)
    }

    @Test("The chart series preserves the shape of ratio readings")
    func series() {
        let status = makeStatus(recent: [0.998, 0.9], state: .armed)

        #expect(status.series.values == [998, 900])
    }

    @Test("Only firing statuses count toward the badge")
    func firingCount() {
        let statuses = [
            makeStatus(recent: [0.9], state: .firing(since: Date(timeIntervalSince1970: 0))),
            makeStatus(recent: [0.998], state: .armed),
            makeStatus(recent: [0.998], state: .muted(until: Date(timeIntervalSince1970: 0))),
        ]

        #expect(statuses.firingCount == 1)
    }

    private func makeStatus(recent: [Double], state: AlertState) -> AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995))
            ),
            outcome: AlertOutcome(state: state, shouldNotify: false),
            reading: MetricReading(baseline: 0.998, recent: recent)
        )
    }
}
