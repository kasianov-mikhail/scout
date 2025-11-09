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

    /// Explicit x‑axis tick positions for monthly charts.
    ///
    /// The default system behavior places ticks on Mondays.
    /// This implementation overrides that behavior to mark exactly 1, 2, 3, and 4 weeks ago
    ///
    var tickValues: [Date]? {
        if case .month = period.rangeComponent {
            [-28, -21, -14, -7].map(domain.upperBound.addingDay)
        } else {
            nil
        }
    }
}
