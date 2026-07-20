//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertBacktestTests {
    private let dropRule = AlertRule(
        metric: .eventCount(name: "Session"),
        condition: AlertCondition(comparison: .below, reference: .constant(5))
    )

    @Test("A history shorter than two windows never fires")
    func shortHistory() {
        let backtest = AlertBacktest(values: Array(repeating: 1, count: 47))

        #expect(backtest.fireCount(for: dropRule) == 0)
    }

    @Test("A healthy history never fires")
    func healthy() {
        let backtest = AlertBacktest(values: Array(repeating: 10, count: 96))

        #expect(backtest.fireCount(for: dropRule) == 0)
    }

    @Test("A single drop fires once")
    func singleDrop() {
        let backtest = AlertBacktest(values: Array(repeating: 10, count: 48) + [1])

        #expect(backtest.fireCount(for: dropRule) == 1)
    }

    @Test("A long-lasting drop still counts as one fire")
    func longDrop() {
        let backtest = AlertBacktest(values: Array(repeating: 10, count: 48) + Array(repeating: 1, count: 5))

        #expect(backtest.fireCount(for: dropRule) == 1)
    }

    @Test("A recovery between drops re-arms and counts a second fire")
    func twoDrops() {
        let backtest = AlertBacktest(values: Array(repeating: 10, count: 48) + [1, 10, 1])

        #expect(backtest.fireCount(for: dropRule) == 2)
    }

    @Test("A spike over the trailing baseline fires")
    func baselineSpike() {
        let rule = AlertRule(
            metric: .eventCount(name: "Error"),
            condition: AlertCondition(comparison: .above, reference: .baselineFactor(2))
        )
        let backtest = AlertBacktest(values: Array(repeating: 4, count: 48) + [20])

        #expect(backtest.fireCount(for: rule) == 1)
    }

    @Test("Summaries phrase zero, one, and many fires")
    func summaries() {
        let none = AlertBacktest(values: Array(repeating: 10, count: 96))
        let once = AlertBacktest(values: Array(repeating: 10, count: 48) + [1])
        let twice = AlertBacktest(values: Array(repeating: 10, count: 48) + [1, 10, 1])

        #expect(none.summary(for: dropRule) == "Would not have fired in the past week")
        #expect(once.summary(for: dropRule) == "Would have fired once in the past week")
        #expect(twice.summary(for: dropRule) == "Would have fired 2 times in the past week")
    }
}
