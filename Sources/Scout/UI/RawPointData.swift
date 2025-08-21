//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A container for chart data points within a specific date range.
struct RawPointData {

    /// The inclusive date range that bounds the data points.
    let range: ClosedRange<Date>

    /// The list of chart points will be grouped by the range.
    let points: [ChartPoint]
}

extension RawPointData {

    /// Groups the chart points into buckets based on the given calendar component.
    ///
    /// For each step of the specified component (such as `.day`, `.weekOfYear`, or `.month`),
    /// the method calculates the sum of counts for all points whose dates fall within that interval.
    ///
    func group(by component: Calendar.Component) -> [ChartPoint] {
        var result: [ChartPoint] = []
        var date = range.lowerBound

        while date < range.upperBound {
            let next = date.adding(component)

            let count = points.filter { item in
                (date..<next).contains(item.date)
            }.reduce(0) {
                $0 + $1.count
            }

            result.append(ChartPoint(date: date, count: count))
            date = next
        }

        return result
    }
}
