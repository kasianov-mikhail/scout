//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension AlertRule {
    private static let windowBuckets = 24

    func backtestFireCount(over values: [Double]) -> Int {
        let window = Self.windowBuckets

        guard values.count >= window * 2 else {
            return 0
        }

        var state = AlertState.armed
        var fires = 0

        for end in (window * 2)...values.count {
            let reading = MetricReading(
                baseline: Array(values[(end - window * 2)..<(end - window)]).median ?? 0,
                recent: Array(values[(end - window)..<end])
            )
            let outcome = self.outcome(reading: reading, state: state, now: Date(timeIntervalSince1970: 0))

            state = outcome.state

            if outcome.shouldNotify {
                fires += 1
            }
        }

        return fires
    }
}
