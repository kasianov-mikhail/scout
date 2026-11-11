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

    @Test("The summary names the threshold and the hold")
    func summary() {
        let stability = makeStatus(recent: [0.998, 0.9], state: .armed)
        #expect(stability.summary == "below 99.50% for 1 h")

        let count = AlertStatus(
            rule: AlertRule(
                metric: .eventCount(name: "Error"),
                condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
            ),
            outcome: AlertOutcome(state: .armed, shouldNotify: false),
            reading: MetricReading(baseline: 4, recent: [4, 4])
        )
        #expect(count.summary == "above 3× median · 12 for 1 h")
    }

    @Test("The value reads the last bucket")
    func value() {
        let status = makeStatus(recent: [0.998, 0.9918], state: .armed)

        #expect(status.value == "99.18%")
    }

    @Test("The firing label counts whole hours")
    func firingLabel() {
        let since = Date(timeIntervalSince1970: 0)
        let status = makeStatus(recent: [0.9], state: .firing(since: since), isRecorded: true)

        #expect(status.firingLabel(now: since.addingTimeInterval(2 * 3600 + 60)) == "Firing 2 h")
    }

    @Test("The firing label omits the hours while the start is unrecorded")
    func unrecordedFiringLabel() {
        let since = Date(timeIntervalSince1970: 0)
        let status = makeStatus(recent: [0.9], state: .firing(since: since))

        #expect(status.firingStart == nil)
        #expect(status.firingLabel(now: since.addingTimeInterval(2 * 3600 + 60)) == "Firing")
    }

    @Test("Statuses group by their state")
    func groups() {
        let armed = makeStatus(recent: [0.998], state: .armed)
        let muted = makeStatus(recent: [0.998], state: .muted(until: Date(timeIntervalSince1970: 0)))
        let firing = makeStatus(recent: [0.9], state: .firing(since: Date(timeIntervalSince1970: 0)))

        let statuses = [armed, muted, firing]

        #expect(statuses.firing == [firing])
        #expect(statuses.armed == [armed])
        #expect(statuses.muted == [muted])
    }

    @Test("The row strip colors only the current breach red")
    func buckets() {
        let status = makeStatus(
            recent: [0.9, 0.998, 0.998, 0.9, 0.9],
            state: .firing(since: Date(timeIntervalSince1970: 0))
        )

        #expect(Array(status.buckets.suffix(5)) == [.muted, .clear, .clear, .firing, .firing])
        #expect(status.buckets.count == 24)
    }

    private func makeStatus(recent: [Double], state: AlertState, isRecorded: Bool = false) -> AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995))
            ),
            outcome: AlertOutcome(state: state, shouldNotify: false, isRecorded: isRecorded),
            reading: MetricReading(baseline: 0.998, recent: recent)
        )
    }
}
