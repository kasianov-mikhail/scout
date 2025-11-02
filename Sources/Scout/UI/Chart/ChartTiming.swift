//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ChartTiming {
    var unit: Calendar.Component { get }
    var tickValues: [Date]? { get }
}

extension ChartExtent: ChartTiming {
    var unit: Calendar.Component {
        period.pointComponent
    }

    var tickValues: [Date]? {
        switch period.rangeComponent {
        case .month:
            [-28, -21, -14, -7].map(domain.upperBound.addingDay)
        case .weekOfYear:
            [-7, -5, -3, -1].map(domain.upperBound.addingDay)
        default:
            nil
        }
    }
}
