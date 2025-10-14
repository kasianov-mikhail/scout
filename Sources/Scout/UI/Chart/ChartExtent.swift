//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ChartExtent<T: ChartTimeScale> {
    var period: T {
        didSet { domain = period.initialRange }
    }
    var domain: Range<Date>
}

extension ChartExtent {
    init(period: T) {
        self.period = period
        self.domain = period.initialRange
    }

    func segment<U: ChartNumeric>(from all: [ChartPoint<U>]) -> [ChartPoint<U>] {
        all.bucket(in: domain, component: period.pointComponent)
    }
}

// MARK: - Axis Values

extension ChartExtent {
    /// Explicit x‑axis tick positions for monthly charts.
    ///
    /// The default system behavior places ticks on Mondays.
    /// This implementation overrides that behavior to mark exactly 1, 2, 3, and 4 weeks ago
    ///
    var axisValues: [Date]? {
        if case .month = period.rangeComponent {
            [-28, -21, -14, -7].map(domain.upperBound.addingDay)
        } else {
            nil
        }
    }
}
