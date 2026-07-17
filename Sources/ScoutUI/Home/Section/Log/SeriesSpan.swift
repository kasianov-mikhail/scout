//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

private let categories = Set(MetricsList.Scope.allCases.map(\.telemetry.rawValue))

struct SeriesSpan {
    let series: [MetricSeries]
    let range: Range<Date>

    func points(where isIncluded: (String) -> Bool) -> [ChartPoint<Int>] {
        points { $0.category == nil && isIncluded($0.name) }
    }

    func points(inCategories categories: Set<String>) -> [ChartPoint<Int>] {
        points { $0.category.map(categories.contains) ?? false }
    }

    private func points(matching isIncluded: (MetricSeries) -> Bool) -> [ChartPoint<Int>] {
        series
            .filter(isIncluded)
            .flatMap { $0.chartPoints() as [ChartPoint<Int>] }
            .filter { range.contains($0.date) }
    }

    var metricCount: Int {
        series
            .reduce(into: Set<[String]>()) { keys, series in
                guard let category = series.category, categories.contains(category) else {
                    return
                }
                if series.points.contains(where: { range.contains(Date(millisecondsSince1970: $0.date)) }) {
                    keys.insert([category, series.name])
                }
            }
            .count
    }
}
