//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    /// The same window one `rangeComponent` earlier than the current domain.
    var previousDomain: Range<Date> {
        domain.moved(by: period.rangeComponent, value: -1)
    }

    /// Buckets `points` into the previous window and places the results on
    /// the current window's bucket dates, so each previous value lines up
    /// with the bucket it should be compared against.
    ///
    func referenceSegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        let current = segment(from: points)
        let previous = points.bucket(in: previousDomain, component: period.pointComponent)
        return zip(current, previous).map { ChartPoint(date: $0.date, count: $1.count) }
    }
}
