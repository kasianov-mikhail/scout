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
    var axisValues: [Date]? {
        switch rangeComponent {
        case .month:
            [-28, -21, -14, -7].map(range.upperBound.addingDay)
        default:
            nil
        }
    }
}

extension [ChartTimeScale] {
    var uniqueComponents: Set<Calendar.Component> {
        Set(map(\.pointComponent))
    }
}
