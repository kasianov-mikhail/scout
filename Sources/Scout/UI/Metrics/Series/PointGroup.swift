//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct PointGroup<T: ChartNumeric>: PointSeries, Identifiable {
    let name: String
    let points: [ChartPoint<T>]
    let id = UUID()
}

extension PointGroup: Comparable {
    static func < (lhs: PointGroup<T>, rhs: PointGroup<T>) -> Bool {
        lhs.points.total > rhs.points.total
    }
}

extension [MetricSeries] {
    func pointGroups<T: ChartNumeric>() -> [PointGroup<T>] {
        map { series in
            PointGroup(
                name: series.name,
                points: series.points.map { point in
                    ChartPoint(
                        date: Date(millisecondsSince1970: point.date),
                        count: T.chartValue(point.value)
                    )
                }
            )
        }
    }
}
