//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ChartModel<T: ChartTimeScale> {
    var period: T {
        didSet { range = period.range }
    }
    var range: Range<Date>
}

extension ChartModel {
    init(period: T) {
        self.period = period
        self.range = period.range
    }

    var viewport: ClosedRange<Date> {
        let lowerBound = range.lowerBound
        let upperBound = range.upperBound.adding(period.pointComponent, value: -1)
        return lowerBound...upperBound
    }
}
