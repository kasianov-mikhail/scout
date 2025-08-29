//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatModel<T: ChartCompatible> {
    var period: T {
        didSet { range = period.range }
    }

    var range: Range<Date>

    func points(from data: ChartData<T>?) -> [ChartPoint]? {
        data?[period]?.filter {
            range.contains($0.date)
        }
    }
}

extension StatModel {
    init(period: T) {
        self.period = period
        self.range = period.range
    }
}
