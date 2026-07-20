//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

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
    func referenceSegment<U: ChartNumeric>(from points: [ChartPoint<U>], alignedTo segment: [ChartPoint<U>])
        -> [ChartPoint<U>]
    {
        zip(segment, previousSegment(from: points)).map { ChartPoint(date: $0.date, count: $1.count) }
    }

    /// Whether the comparison overlay has anything to show.
    ///
    /// True when the current or the previous window holds any data; when
    /// both are empty the comparison toggle is shown disabled.
    ///
    /// `segment` is the current window's segment, which callers have already
    /// computed.
    ///
    func canCompare<U: ChartNumeric>(points: [ChartPoint<U>], segment: [ChartPoint<U>]) -> Bool {
        segment.total != .zero || previousSegment(from: points).total != .zero
    }

    /// Buckets `points` into the previous window.
    private func previousSegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(in: previousDomain, component: period.pointComponent)
    }
}
