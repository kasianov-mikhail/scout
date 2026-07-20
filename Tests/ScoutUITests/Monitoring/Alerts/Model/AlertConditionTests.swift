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

    @Test("An unresolvable reference never breaches")
    func unresolvable() {
        let empty = MetricReading(baseline: 0, recent: [])
        let condition = AlertCondition(comparison: .above, reference: .baselineFactor(2))

        #expect(!condition.isBreached(by: 1000, in: empty))
    }
}
