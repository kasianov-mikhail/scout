//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ChartExtent {
    var isLeftEnabled: Bool {
        let yearRange = Period.year.initialRange
        let leftRange = period.range(at: offset - 1)
        return yearRange.lowerBound < leftRange.lowerBound
    }

    var isRightEnabled: Bool {
        offset < 0
    }

    mutating func moveLeft() {
        offset -= 1
    }

    mutating func moveRight() {
        offset += 1
    }

    mutating func moveRightEdge() {
        offset = 0
    }
}

extension Range<Date> {
    func moved(by component: Calendar.Component, value: Int) -> Self {
        let lowerBound = lowerBound.adding(component, value: value)
        let upperBound = upperBound.adding(component, value: value)
        return lowerBound..<upperBound
    }
}
