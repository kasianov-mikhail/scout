//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertMessageTests {
    @Test("A crash-free breach reads as percentages against the threshold")
    func crashFree() throws {
        let message = try #require(
            AlertMessage(
                status: makeStatus(
                    metric: .crashFreeSessions,
                    condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
                    recent: [0.998, 0.9]
                )
            )
        )

        #expect(message.title == "Crash-free sessions")
        #expect(message.body == "90.00% — below 99.50%")
    }

    @Test("An event spike over the baseline reads as counts against the factor")
    func baseline() throws {
        let message = try #require(
            AlertMessage(
                status: makeStatus(
                    metric: .eventCount(name: "Error"),
                    condition: AlertCondition(comparison: .above, reference: .baselineFactor(2)),
                    recent: [4, 20]
                )
            )
        )

        #expect(message.title == "Error")
        #expect(message.body == "20 — above 2× baseline")
    }

    @Test("A spike over the median names the median factor")
    func median() throws {
        let message = try #require(
            AlertMessage(
                status: makeStatus(
                    metric: .eventCount(name: "Error"),
                    condition: AlertCondition(comparison: .above, reference: .medianFactor(3)),
                    recent: [4, 148]
                )
            )
        )

        #expect(message.body == "148 — above 3× median")
    }

    @Test("A silent outcome carries no message")
    func silent() {
        let status = makeStatus(
            metric: .crashFreeSessions,
            condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
            recent: [0.9],
            shouldNotify: false
        )

        #expect(AlertMessage(status: status) == nil)
    }

    @Test("An empty reading carries no message")
    func empty() {
        let status = makeStatus(
            metric: .crashFreeSessions,
            condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
            recent: []
        )

        #expect(AlertMessage(status: status) == nil)
    }

    @Test("A rule with delivery switched off carries no message")
    func deliveryOff() {
        let status = makeStatus(
            metric: .crashFreeSessions,
            condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
            recent: [0.9],
            notifies: false
        )

        #expect(AlertMessage(status: status) == nil)
    }

    private func makeStatus(
        metric: AlertMetric, condition: AlertCondition, recent: [Double], shouldNotify: Bool = true,
        notifies: Bool = true
    ) -> AlertStatus {
        AlertStatus(
            rule: AlertRule(metric: metric, condition: condition, notifies: notifies),
            outcome: AlertOutcome(state: .firing(since: Date(timeIntervalSince1970: 0)), shouldNotify: shouldNotify),
            reading: MetricReading(baseline: 0, recent: recent)
        )
    }
}
