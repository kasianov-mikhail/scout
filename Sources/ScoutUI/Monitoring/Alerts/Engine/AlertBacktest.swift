//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertBacktest: Equatable {
    static let windowBuckets = 24

    let values: [Double]

    func fireCount(for rule: AlertRule) -> Int {
        let window = Self.windowBuckets
        let evaluator = AlertEvaluator()

        guard values.count >= window * 2 else { return 0 }

        var state = AlertState.armed
        var fires = 0

        for end in (window * 2)...values.count {
            let reading = MetricReading(
                baseline: Array(values[(end - window * 2)..<(end - window)]).median ?? 0,
                recent: Array(values[(end - window)..<end])
            )
            let outcome = evaluator.evaluate(rule, reading: reading, state: state, now: Date(timeIntervalSince1970: 0))

            state = outcome.state

            if outcome.shouldNotify {
                fires += 1
            }
        }

        return fires
    }

    func summary(for rule: AlertRule) -> String {
        switch fireCount(for: rule) {
        case 0:
            "Would not have fired in the past week"
        case 1:
            "Would have fired once in the past week"
        case let count:
            "Would have fired \(count) times in the past week"
        }
    }
}
