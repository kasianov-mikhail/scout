//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartTimeScale: Identifiable, Hashable {
    var pointComponent: Calendar.Component { get }
    var rangeComponent: Calendar.Component { get }

    var range: Range<Date> { get }
}

extension ChartTimeScale {

    /// These values are intended for intermediate tick marks on a monthly time
    /// axis. They are computed by offsetting `range.lowerBound` by whole-day
    /// increments (negative offsets move backward in time).
    ///
    var axisValues: [Date]? {
//        if case .month = pointComponent {
//            [-28, -21, -14, -7].map(range.lowerBound.addingDay)
//        } else {
            nil
//        }
    }
}
