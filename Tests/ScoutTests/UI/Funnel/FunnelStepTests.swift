//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct FunnelStepTests {
    @Test("Metrics derive fractions, conversions, and drop-offs")
    func derivesMetrics() {
        let steps = [
            FunnelStep(name: "open", count: 100),
            FunnelStep(name: "signup", count: 40),
            FunnelStep(name: "purchase", count: 10),
        ]

        let metrics = steps.metrics

        #expect(metrics.map(\.fractionOfFirst) == [1, 0.4, 0.1])
        #expect(metrics.map(\.conversionFromPrevious) == [nil, 0.4, 0.25])
        #expect(metrics.map(\.dropOff) == [0, 60, 30])
        #expect(metrics.map(\.index) == [0, 1, 2])
    }

    @Test("Metrics are empty when the first step has no data")
    func emptyWhenFirstStepIsZero() {
        let steps = [
            FunnelStep(name: "open", count: 0),
            FunnelStep(name: "signup", count: 0),
        ]

        #expect(steps.metrics.count == 0)
        #expect([FunnelStep]().metrics.count == 0)
    }
}
