//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Helper methods for `RangeControl` and `PeriodPicker`.
extension StatModel {

    /// A computed property that indicates whether moving left is enabled.
    ///
    /// This property checks if the current range can be moved left without exceeding the lower bound
    /// of the year range.
    ///
    var isLeftEnabled: Bool {
        let yearRange = Period.year.range
        let leftRange = range.moved(by: period.rangeComponent, value: -1)
        return yearRange.lowerBound < leftRange.lowerBound
    }

    /// A computed property that indicates whether moving right is enabled.
    ///
    /// This property checks if the current range is not equal to the period range.
    ///
    var isRightEnabled: Bool {
        range != period.range
    }

    /// Moves the range to the left by the specified period component.
    func moveLeft() {
        range.move(by: period.rangeComponent, value: -1)
    }

    /// Moves the range to the right by the specified period component.
    func moveRight() {
        range.move(by: period.rangeComponent, value: 1)
    }

    /// Moves the range to the right edge of the period range.
    func moveRightEdge() {
        range = period.range
    }
}

// MARK: - Range Extension

extension Range<Date> {

    /// Moves the range by the specified calendar component and value.
    ///
    /// This method adjusts the range by moving its lower and upper bounds based on the given
    /// calendar component and value.
    ///
    /// - Parameters:
    ///   - component: The calendar component to move by (e.g., day, month, year).
    ///   - value: The value to move by (positive for forward, negative for backward).
    ///
    mutating func move(by component: Calendar.Component, value: Int) {
        self = moved(by: component, value: value)
    }

    /// Returns a new range moved by the specified calendar component and value.
    ///
    /// This method creates a new range by adjusting its lower and upper bounds based on the given
    /// calendar component and value.
    ///
    /// - Parameters:
    ///   - component: The calendar component to move by (e.g., day, month, year).
    ///   - value: The value to move by (positive for forward, negative for backward).
    /// - Returns: A new range moved by the specified component and value.
    ///
    func moved(by component: Calendar.Component, value: Int) -> Self {
        let lowerBound = lowerBound.adding(component, value: value)
        let upperBound = upperBound.adding(component, value: value)
        return lowerBound..<upperBound
    }
}
