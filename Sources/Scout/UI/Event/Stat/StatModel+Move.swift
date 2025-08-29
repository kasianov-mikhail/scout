//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension StatModel {
    var isLeftEnabled: Bool {
        let yearRange = Period.year.range
        let leftRange = range.moved(by: period.rangeComponent, value: -1)
        return yearRange.lowerBound < leftRange.lowerBound
    }

    var isRightEnabled: Bool {
        range != period.range
    }
}

extension StatModel {
    mutating func moveLeft() {
        range.move(by: period.rangeComponent, value: -1)
    }

    mutating func moveRight() {
        range.move(by: period.rangeComponent, value: 1)
    }

    mutating func moveRightEdge() {
        range = period.range
    }
}

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
