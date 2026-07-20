//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct AlertRule: Hashable, Codable {
    let metric: AlertMetric
    let condition: AlertCondition
    let holdBuckets: Int
    let notifies: Bool

    init(metric: AlertMetric, condition: AlertCondition, holdBuckets: Int = 1, notifies: Bool = true) {
        self.metric = metric
        self.condition = condition
        self.holdBuckets = holdBuckets
        self.notifies = notifies
    }
}

extension AlertRule {
    func isSustained(in reading: MetricReading) -> Bool {
        let window = reading.recent.suffix(holdBuckets)

        return window.count == holdBuckets
            && window.allSatisfy { condition.isBreached(by: $0, in: reading) }
    }
}
