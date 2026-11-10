//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation
import Scout

typealias ChartNumeric = Plottable & MetricScalar

struct ChartPoint<T: ChartNumeric>: ChartSeries {
    let date: Date
    let value: T
}

extension ChartPoint: Comparable {
    static func < (lhs: ChartPoint, rhs: ChartPoint) -> Bool {
        lhs.date < rhs.date
    }
}

extension ChartPoint: Fixture where T == Int {
    static var samples: [ChartPoint<Int>] {
        let base = Date().trailingYear.lowerBound
        return (1...372).map { day in
            ChartPoint(
                date: base.addingTimeInterval(TimeInterval(day - 1) * .day + 12 * .hour),
                value: 12 + day % 40 + (day / 9) % 18
            )
        }
    }
}

extension [ChartPoint<Int>] {
    static let empty: Self = []
}
