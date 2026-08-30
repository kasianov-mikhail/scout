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

        #expect(reading.reference(for: .constant(0.995)) == 0.995)
    }

    @Test("A baseline factor scales the previous window's value")
    func baselineFactor() {
        let reading = MetricReading(baseline: 200, recent: [])

        #expect(reading.reference(for: .baselineFactor(2)) == 400)
    }

    @Test("An empty baseline has nothing to compare against")
    func emptyBaseline() {
        let reading = MetricReading(baseline: 0, recent: [])

        #expect(reading.reference(for: .baselineFactor(2)) == nil)
    }

    @Test("A median factor scales the middle of an odd-count history")
    func medianFactorOdd() {
        let reading = MetricReading(baseline: 0, recent: [8, 2, 4])

        #expect(reading.reference(for: .medianFactor(3)) == 12)
    }

    @Test("A median factor averages the middle pair of an even-count history")
    func medianFactorEven() {
        let reading = MetricReading(baseline: 0, recent: [8, 2, 4, 6])

        #expect(reading.reference(for: .medianFactor(2)) == 10)
    }

    @Test("An empty history has no median to scale")
    func emptyHistory() {
        let reading = MetricReading(baseline: 100, recent: [])

        #expect(reading.reference(for: .medianFactor(3)) == nil)
    }
}
