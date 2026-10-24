//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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
        period.range(at: offset)
    }

    func segment<U: ChartNumeric>(from points: [ChartPoint<U>]) -> [ChartPoint<U>] {
        points.bucket(in: domain, component: period.pointComponent, fold: fold)
    }
}
