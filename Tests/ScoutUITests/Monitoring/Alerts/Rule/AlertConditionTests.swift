//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct AlertConditionTests {
    private let reading = MetricReading(baseline: 100, recent: [])

    @Test("Falling below the reference is a breach")
    func below() {
        let condition = AlertCondition(comparison: .below, reference: .constant(0.995))

        #expect(condition.isBreached(by: 0.99, in: reading))
        #expect(!condition.isBreached(by: 0.998, in: reading))
    }

    @Test("Rising above the reference is a breach")
    func above() {
        let condition = AlertCondition(comparison: .above, reference: .baselineFactor(2))

        #expect(condition.isBreached(by: 230, in: reading))
        #expect(!condition.isBreached(by: 180, in: reading))
    }

    @Test("Sitting exactly on the reference is not a breach")
    func equal() {
        let below = AlertCondition(comparison: .below, reference: .constant(0.995))
        let above = AlertCondition(comparison: .above, reference: .constant(0.995))

        #expect(!below.isBreached(by: 0.995, in: reading))
        #expect(!above.isBreached(by: 0.995, in: reading))
    }

    @Test("A spike over an empty baseline is a breach, but a single event is not")
    func emptyBaselineAbove() {
        let quiet = MetricReading(baseline: 0, recent: [])
        let condition = AlertCondition(comparison: .above, reference: .baselineFactor(2))

        #expect(condition.isBreached(by: 50, in: quiet))
        #expect(condition.isBreached(by: 3, in: quiet))
        #expect(!condition.isBreached(by: 2, in: quiet))
        #expect(!condition.isBreached(by: 1, in: quiet))
    }

    @Test("Nothing falls below an empty baseline")
    func emptyBaselineBelow() {
        let quiet = MetricReading(baseline: 0, recent: [])
        let condition = AlertCondition(comparison: .below, reference: .baselineFactor(0.5))

        #expect(!condition.isBreached(by: 0, in: quiet))
    }

    @Test("A zero median breaches the same way as an empty baseline")
    func zeroMedian() {
        let quiet = MetricReading(baseline: 0, recent: [0, 0, 0, 0, 50])
        let above = AlertCondition(comparison: .above, reference: .medianFactor(2))
        let below = AlertCondition(comparison: .below, reference: .medianFactor(0.5))

        #expect(above.isBreached(by: 50, in: quiet))
        #expect(!above.isBreached(by: 2, in: quiet))
        #expect(!below.isBreached(by: 0, in: quiet))
    }

    @Test("An unresolvable reference never breaches")
    func unresolvable() {
        let empty = MetricReading(baseline: 0, recent: [])
        let condition = AlertCondition(comparison: .above, reference: .medianFactor(3))

        #expect(!condition.isBreached(by: 1000, in: empty))
    }
}
