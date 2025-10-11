//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    func segment<U: HasDate>(from all: [U]) -> [U] {
        all.segment(in: viewport)
    }

    func segment<U: HasDate>(from all: [U]?) -> [U]? {
        all?.segment(in: viewport)
    }
}

extension ChartExtent {
    fileprivate var viewport: ClosedRange<Date> {
        domain.aligned(to: period.pointComponent)
    }
}

extension Range where Bound == Date {
    fileprivate func aligned(to component: Calendar.Component) -> ClosedRange<Bound> {
        lowerBound...upperBound.adding(component, value: -1)
    }
}
