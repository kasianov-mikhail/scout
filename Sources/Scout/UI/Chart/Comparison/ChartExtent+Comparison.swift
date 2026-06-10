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
    /// the bucket dates of `segment`, pairing buckets by their offset from
    /// the period's end.
    ///
    /// `segment` is the current window's segment, which callers have already
    /// computed. When the previous window spans fewer buckets (calendar
    /// months differ in length), the oldest current buckets have no
    /// counterpart and are omitted; the chart draws no reference for them.
    ///
    func referenceSegment<U: ChartNumeric>(from points: [ChartPoint<U>], alignedTo segment: [ChartPoint<U>]) -> [ChartPoint<U>] {
        let previous = points.bucket(in: previousDomain, component: period.pointComponent)
        return zip(segment, previous).map { ChartPoint(date: $0.date, count: $1.count) }
    }
}
