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

// MARK: - Segments

extension Array where Element: HasDate {
    func segment(using model: ChartModel<some ChartTimeScale>) -> [Element] {
        segment(in: model.viewport)
    }
}

extension ChartModel {
    fileprivate var viewport: ClosedRange<Date> {
        domain.aligned(to: period.pointComponent)
    }
}

extension Range where Bound == Date {
    fileprivate func aligned(to component: Calendar.Component) -> ClosedRange<Bound> {
        lowerBound...upperBound.adding(component, value: -1)
    }
}
