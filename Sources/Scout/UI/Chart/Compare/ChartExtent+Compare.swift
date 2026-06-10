//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

extension ChartExtent {
    /// The date range immediately preceding the visible domain, one period back.
    var previousDomain: Range<Date> {
        domain.moved(by: period.rangeComponent, value: -1)
    }

    /// A comparison series for the period preceding the visible domain.
    ///
    /// Buckets the points into the previous period and shifts the result forward
    /// by one period so both series align on the current domain's axis.
    /// Returns `nil` when comparison is turned off.
    ///
    func comparison<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>]? {
        guard isComparing else { return nil }

        return points.bucket(in: previousDomain, component: period.pointComponent).map { point in
            ChartPoint(date: point.date.adding(period.rangeComponent), count: point.count)
        }
    }
}
