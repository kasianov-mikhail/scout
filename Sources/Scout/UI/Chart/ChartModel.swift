//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ChartModel<T: ChartTimeScale> {
    var period: T {
        didSet { domain = period.initialRange }
    }
    var domain: Range<Date>
}

extension ChartModel {
    init(period: T) {
        self.period = period
        self.domain = period.initialRange
    }
}
