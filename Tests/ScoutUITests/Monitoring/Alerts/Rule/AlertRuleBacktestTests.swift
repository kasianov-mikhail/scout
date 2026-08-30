//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertRuleBacktestTests {
    private let dropRule = AlertRule(
        metric: .eventCount(name: "Session"),
        condition: AlertCondition(comparison: .below, reference: .constant(5))
    )

    @Test("A history shorter than two windows never fires")
    func shortHistory() {
        #expect(dropRule.backtestFireCount(over: Array(repeating: 1, count: 47)) == 0)
    }

    @Test("A healthy history never fires")
    func healthy() {
        #expect(dropRule.backtestFireCount(over: Array(repeating: 10, count: 96)) == 0)
    }

    @Test("A single drop fires once")
    func singleDrop() {
        #expect(dropRule.backtestFireCount(over: Array(repeating: 10, count: 48) + [1]) == 1)
    }

    @Test("A long-lasting drop still counts as one fire")
    func longDrop() {
        #expect(dropRule.backtestFireCount(over: Array(repeating: 10, count: 48) + Array(repeating: 1, count: 5)) == 1)
    }

    @Test("A recovery between drops re-arms and counts a second fire")
    func twoDrops() {
        #expect(dropRule.backtestFireCount(over: Array(repeating: 10, count: 48) + [1, 10, 1]) == 2)
    }

    @Test("A spike over the trailing baseline fires")
    func baselineSpike() {
        let rule = AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .baselineFactor(2))
        )

        #expect(rule.backtestFireCount(over: Array(repeating: 4, count: 48) + [20]) == 1)
    }

    @Test("Summaries phrase zero, one, and many fires")
    func summaries() {
        let none = Array(repeating: 10.0, count: 96)
        let once = Array(repeating: 10.0, count: 48) + [1]
        let twice = Array(repeating: 10.0, count: 48) + [1, 10, 1]

        #expect(dropRule.backtestSummary(over: none) == "Would not have fired in the past week")
        #expect(dropRule.backtestSummary(over: once) == "Would have fired once in the past week")
        #expect(dropRule.backtestSummary(over: twice) == "Would have fired 2 times in the past week")
    }
}
