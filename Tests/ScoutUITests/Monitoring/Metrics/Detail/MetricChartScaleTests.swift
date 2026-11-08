//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI

@Suite("MetricChartScale")
struct MetricChartScaleTests {
    @Test("An empty chart has no ticks")
    func empty() {
        let scale = MetricChartScale(values: [])

        #expect(scale.upper == 1)
        #expect(scale.ticks.isEmpty)
    }

    @Test("The axis rounds up to a readable step")
    func counter() {
        let scale = MetricChartScale(values: [162])

        #expect(scale.upper == 200)
        #expect(scale.ticks == [50, 100, 150, 200])
    }

    @Test("A small gauge keeps every tick")
    func gauge() {
        let scale = MetricChartScale(values: [47])

        #expect(scale.upper == 50)
        #expect(scale.ticks == [10, 20, 30, 40, 50])
    }

    @Test("A recorder counts in hundreds")
    func recorder() {
        let scale = MetricChartScale(values: [284])

        #expect(scale.upper == 300)
        #expect(scale.ticks == [100, 200, 300])
    }

    @Test("A timer axis uses fractions of a second")
    func timer() {
        let scale = MetricChartScale(values: [0.52])

        #expect(abs(scale.upper - 0.6) < 0.000_001)
        #expect(scale.ticks.count == 3)
    }
}
