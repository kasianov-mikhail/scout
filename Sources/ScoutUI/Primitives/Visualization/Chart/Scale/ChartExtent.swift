//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ChartExtent<T: ChartTimeScale> {
    var period: T {
        didSet { offset = 0 }
    }
    var offset = 0
    var fold = ChartFold.total
}

extension ChartExtent {
    var domain: Range<Date> {
        let range = period.range(at: offset)
        guard case .month = period.pointComponent, range.upperBound != range.upperBound.startOfMonth else {
            return range
        }
        let upperBound = range.upperBound.startOfMonth.addingMonth()
        return upperBound.adding(period.rangeComponent, value: -1)..<upperBound
    }

    func segment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(in: domain, component: period.pointComponent, fold: fold)
    }
}
