//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertRuleTests {
    @Test("The default hold fires on the last bucket alone")
    func defaultHold() {
        let rule = makeRule()
        let reading = MetricReading(baseline: 0, recent: [0.998, 0.997, 0.99])

        #expect(rule.isSustained(in: reading))
    }

    @Test("A breach in only the last of three held buckets does not sustain")
    func partialHold() {
        let rule = makeRule(holdBuckets: 3)
        let reading = MetricReading(baseline: 0, recent: [0.998, 0.997, 0.99])

        #expect(!rule.isSustained(in: reading))
    }

    @Test("A breach across the full hold window sustains")
    func fullHold() {
        let rule = makeRule(holdBuckets: 3)
        let reading = MetricReading(baseline: 0, recent: [0.998, 0.994, 0.993, 0.99])

        #expect(rule.isSustained(in: reading))
    }

    @Test("A history shorter than the hold window cannot sustain")
    func shortHistory() {
        let rule = makeRule(holdBuckets: 3)
        let reading = MetricReading(baseline: 0, recent: [0.99, 0.99])

        #expect(!rule.isSustained(in: reading))
    }

    @Test("A spike over the median of a flat history sustains")
    func spike() {
        let rule = AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
        )
        let reading = MetricReading(baseline: 0, recent: [4, 3, 4, 5, 3, 4, 14])

        #expect(rule.isSustained(in: reading))
    }

    @Test("A flat history without a spike stays quiet")
    func flat() {
        let rule = AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
        )
        let reading = MetricReading(baseline: 0, recent: [4, 3, 4, 5, 3, 4, 5])

        #expect(!rule.isSustained(in: reading))
    }

    private func makeRule(holdBuckets: Int = 1) -> AlertRule {
        AlertRule(
            metric: .crashFreeSessions,
            condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
            holdBuckets: holdBuckets
        )
    }
}
