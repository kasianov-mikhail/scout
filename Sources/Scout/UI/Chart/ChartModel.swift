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

extension ChartModel {
    func segment<U: HasDate>(from all: [U]) -> [U] {
        all.segment(in: viewport)
    }

    func segment<U: HasDate>(from all: [U]?) -> [U]? {
        all?.segment(in: viewport)
    }

    private var viewport: ClosedRange<Date> {
        domain.aligned(to: period.pointComponent)
    }
}

extension Range where Bound == Date {
    fileprivate func aligned(to component: Calendar.Component) -> ClosedRange<Bound> {
        lowerBound...upperBound.adding(component, value: -1)
    }
}
