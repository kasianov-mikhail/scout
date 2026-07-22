//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct Trend {
    let count: Int?
    let delta: Delta?
    let series: MiniChartSeries?
}

extension Trend {
    static let loading = Trend(count: nil, delta: nil, series: nil)

    init(points: [ChartPoint<Int>], period: some ChartTimeScale) {
        let current = points.bucket(on: period).total
        let previous = points.bucket(in: period.previousRange, component: period.pointComponent).total

        count = current
        delta = Delta(current: current, previous: previous)
        series = MiniChartSeries(points: points, range: period.initialRange, aggregation: .total)
    }

    init(levels: [ChartPoint<Int>], period: some ChartTimeScale) {
        let current = levels.latest(in: period.initialRange) ?? 0
        let previous = levels.latest(in: period.previousRange) ?? 0

        count = current
        delta = Delta(current: current, previous: previous)
        series = MiniChartSeries(points: levels, range: period.initialRange, aggregation: .latest)
    }

    init(count: Int, previous: Int, values: [Int]) {
        self.count = count
        delta = Delta(current: count, previous: previous)
        series = MiniChartSeries(values: values)
    }
}
