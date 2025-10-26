//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol BucketPoint: HasCount {
    var date: Date { get }

    init(date: Date, count: Count)
}

extension Collection where Element: BucketPoint {

    func bucket(on period: some ChartTimeScale) -> [Element] {
        bucket(in: period.initialRange, component: period.pointComponent)
    }

    /// Groups chart points into contiguous date buckets and sums their counts.
    ///
    /// Provide an explicit date range and calendar component to produce one result
    /// per interval. Each result uses the interval’s start date and the aggregated
    /// count of points whose dates fall inside that interval.
    ///
    func bucket(in range: Range<Date>, component: Calendar.Component) -> [Element] {
        var result: [Element] = []
        var date = range.upperBound

        while date > range.lowerBound {
            let newDate = date.adding(component, value: -1)
            let points = filter {
                newDate..<date ~= $0.date
            }
            result.append(Element(date: newDate, count: points.total))
            date = newDate
        }

        return result
    }
}
