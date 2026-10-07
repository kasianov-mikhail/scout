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

    init(latest: [ActivityPoint], period: Period) {
        let levels = latest.points(on: period.activityPeriod)
        let current = levels.latest(in: period.initialRange)
        let previous = levels.latest(in: period.previousRange)

        self.init(
            count: current,
            delta: Delta(current: current, previous: previous),
            series: MiniChartSeries(points: levels, range: period.initialRange, aggregation: .latest)
        )
    }

    init(total: [ChartPoint<Int>], period: some ChartTimeScale) {
        let current = total.total(in: period.initialRange)
        let previous = total.total(in: period.previousRange)

        self.init(
            count: current,
            delta: Delta(current: current, previous: previous),
            series: MiniChartSeries(points: total, range: period.initialRange, aggregation: .total)
        )
    }
}

extension Trend {
    init(count: Int, previous: Int, values: [Int]) {
        self.count = count
        delta = Delta(current: count, previous: previous)
        series = MiniChartSeries(values: values)
    }
}
