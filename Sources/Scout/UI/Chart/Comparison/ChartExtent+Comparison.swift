//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    /// The time window immediately preceding the visible domain.
    var previousDomain: Range<Date> {
        domain.moved(by: period.rangeComponent, value: -1)
    }

    /// A copy of the extent that looks at the previous time window.
    var previousExtent: ChartExtent {
        ChartExtent(period: period, domain: previousDomain)
    }

    /// Groups points that fall inside the previous time window into buckets.
    func previousSegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(in: previousDomain, component: period.pointComponent)
    }

    /// Re-dates the previous window's buckets onto the current domain so that
    /// both periods share the x-axis in overlay mode.
    ///
    /// Both segments are built from the newest bucket backwards, so pairing by
    /// position matches every bucket with its counterpart one period earlier.
    /// Buckets of the previous window without a counterpart are dropped.
    ///
    func overlaySegment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        zip(segment(from: points), previousSegment(from: points)).map { current, previous in
            ChartPoint(date: current.date, count: previous.count)
        }
    }
}
