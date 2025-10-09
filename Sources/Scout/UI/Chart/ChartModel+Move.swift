//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartModel {
    var isLeftEnabled: Bool {
        let yearRange = Period.year.initialRange
        let leftRange = domain.moved(by: period.rangeComponent, value: -1)
        return yearRange.lowerBound < leftRange.lowerBound
    }

    var isRightEnabled: Bool {
        domain != period.initialRange
    }
}

extension ChartModel {
    mutating func moveLeft() {
        domain.move(by: period.rangeComponent, value: -1)
    }

    mutating func moveRight() {
        domain.move(by: period.rangeComponent, value: 1)
    }

    mutating func moveRightEdge() {
        domain = period.initialRange
    }
}

// MARK: - Date Range Moving

extension Range<Date> {
    mutating func move(by component: Calendar.Component, value: Int) {
        self = moved(by: component, value: value)
    }

    func moved(by component: Calendar.Component, value: Int) -> Self {
        let lowerBound = lowerBound.adding(component, value: value)
        let upperBound = upperBound.adding(component, value: value)
        return lowerBound..<upperBound
    }
}
