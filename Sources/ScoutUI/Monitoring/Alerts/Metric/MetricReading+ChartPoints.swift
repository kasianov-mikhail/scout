//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension MetricReading {
    init(points: [ChartPoint<Int>], period: some ChartTimeScale) {
        let previous = points.bucket(in: period.previousRange, component: period.pointComponent)
        let current = points.bucket(on: period)

        self.init(
            baseline: previous.map { Double($0.value) }.median ?? 0,
            recent: current.reversed().map { Double($0.value) }
        )
    }

    init(stability: StabilityPoints, period: some ChartTimeScale) {
        self.init(
            baseline: stability.values(range: period.previousRange, component: period.pointComponent).median ?? 0,
            recent: stability.values(range: period.initialRange, component: period.pointComponent)
        )
    }
}
