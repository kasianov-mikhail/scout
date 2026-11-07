//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct ActiveUsersMetricTests {
    @Test("The delta is the change from the previous day to the latest one")
    func delta() {
        let metric = ActiveUsersMetric(kind: .dau, series: [80, 100, 120])

        #expect(metric.value == 120)
        #expect(metric.delta == 0.2)
        #expect(metric.deltaLabel == "+20%")
    }

    @Test("A single value or a zero base gives no delta")
    func degenerateSeries() {
        let single = ActiveUsersMetric(kind: .dau, series: [5])
        let empty = ActiveUsersMetric(kind: .sessions, series: [])
        let zeroBase = ActiveUsersMetric(kind: .devices, series: [0, 4])

        #expect(single.value == 5)
        #expect(single.delta == 0)
        #expect(empty.value == 0)
        #expect(empty.delta == 0)
        #expect(zeroBase.delta == 0)
    }
}
