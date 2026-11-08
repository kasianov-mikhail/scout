//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension AlertStatus: Fixture {
    static var samples: [AlertStatus] {
        [.firingSample] + armedSamples + [.mutedSample]
    }

    static var firingSample: AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .crashFreeSessions,
                condition: AlertCondition(comparison: .below, reference: .constant(0.995)),
                holdBuckets: 2
            ),
            outcome: AlertOutcome(
                state: .firing(since: Date(timeIntervalSinceNow: -2 * 3600)),
                shouldNotify: false
            ),
            reading: MetricReading(
                baseline: 0.998,
                recent: Array(repeating: 0.998, count: 17)
                    + [0.994, 0.993, 0.9925, 0.9922, 0.992, 0.9919, 0.9918]
            )
        )
    }

    static var armedSamples: [AlertStatus] {
        [
            AlertStatus(
                rule: AlertRule(
                    metric: .eventCount(name: "PaymentDeclined"),
                    condition: AlertCondition(comparison: .above, reference: .baselineFactor(2))
                ),
                outcome: AlertOutcome(state: .armed, shouldNotify: false),
                reading: MetricReading(
                    baseline: 11,
                    recent: [14, 14, 14, 14, 14, 14, 24] + Array(repeating: 14, count: 17)
                )
            ),
            AlertStatus(
                rule: AlertRule(
                    metric: .eventCount(name: "Error"),
                    condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
                ),
                outcome: AlertOutcome(state: .armed, shouldNotify: false),
                reading: MetricReading(
                    baseline: 4,
                    recent: [4, 5, 4, 3, 4, 5, 4, 4, 3, 4, 4, 5, 4, 4, 3, 4, 4, 4, 5, 4, 3, 4, 4, 5]
                )
            ),
            AlertStatus(
                rule: AlertRule(
                    metric: .eventCount(name: "CheckoutCompleted"),
                    condition: AlertCondition(comparison: .below, reference: .constant(100)),
                    holdBuckets: 2
                ),
                outcome: AlertOutcome(state: .armed, shouldNotify: false),
                reading: MetricReading(
                    baseline: 162,
                    recent: [162, 162, 95, 95, 95, 95, 95]
                        + Array(repeating: 162, count: 17)
                )
            ),
            AlertStatus(
                rule: AlertRule(
                    metric: .eventCount(name: "ProductDetailCheckoutPaymentError"),
                    condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
                ),
                outcome: AlertOutcome(state: .armed, shouldNotify: false),
                reading: MetricReading(baseline: 0, recent: Array(repeating: 0, count: 24))
            ),
        ]
    }

    static var armedSample: AlertStatus {
        armedSamples[1]
    }

    static var mutedSample: AlertStatus {
        AlertStatus(
            rule: AlertRule(
                metric: .eventCount(name: "IPRecordFailed"),
                condition: AlertCondition(comparison: .above, reference: .medianFactor(3))
            ),
            outcome: AlertOutcome(
                state: .muted(until: Date(timeIntervalSinceNow: 3600)),
                shouldNotify: false
            ),
            reading: MetricReading(
                baseline: 3,
                recent: Array(repeating: 3, count: 21) + [20, 3, 8]
            )
        )
    }
}
