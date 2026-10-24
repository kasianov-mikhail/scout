//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

struct MetricReadingTests {
    @Test("A constant reference passes through untouched")
    func constant() {
        let reading = MetricReading(baseline: 100, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .below, reference: .constant(0.995))) == 0.995)
    }

    @Test("A baseline factor scales the previous window's value")
    func baselineFactor() {
        let reading = MetricReading(baseline: 200, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .baselineFactor(2))) == 400)
    }

    @Test("A rise over an empty baseline is measured from one unit")
    func emptyBaselineAbove() {
        let reading = MetricReading(baseline: 0, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .baselineFactor(2))) == 2)
    }

    @Test("A rise over a baseline under one unit is measured from one unit")
    func fractionalBaselineAbove() {
        let reading = MetricReading(baseline: 0.5, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .baselineFactor(2))) == 2)
    }

    @Test("A drop under an empty baseline keeps a zero reference")
    func emptyBaselineBelow() {
        let reading = MetricReading(baseline: 0, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .below, reference: .baselineFactor(0.5))) == 0)
    }

    @Test("A median factor scales the middle of an odd-count history")
    func medianFactorOdd() {
        let reading = MetricReading(baseline: 0, recent: [8, 2, 4])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .medianFactor(3))) == 12)
    }

    @Test("A median factor averages the middle pair of an even-count history")
    func medianFactorEven() {
        let reading = MetricReading(baseline: 0, recent: [8, 2, 4, 6])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .medianFactor(2))) == 10)
    }

    @Test("A rise over a zero median is measured from one unit, like the baseline")
    func zeroMedianAbove() {
        let reading = MetricReading(baseline: 0, recent: [0, 0, 0, 50])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .medianFactor(3))) == 3)
    }

    @Test("A drop under a zero median keeps a zero reference")
    func zeroMedianBelow() {
        let reading = MetricReading(baseline: 0, recent: [0, 0, 0, 50])

        #expect(reading.reference(for: AlertCondition(comparison: .below, reference: .medianFactor(0.5))) == 0)
    }

    @Test("An empty history has no median to scale")
    func emptyHistory() {
        let reading = MetricReading(baseline: 100, recent: [])

        #expect(reading.reference(for: AlertCondition(comparison: .above, reference: .medianFactor(3))) == nil)
    }
}
