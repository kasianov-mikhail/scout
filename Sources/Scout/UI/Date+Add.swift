//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {

    /// Returns a new date by adding a specified component and value to the current date.
    ///
    /// - Parameters:
    ///   - component: The calendar component to add (e.g., day, month, year).
    ///   - value: The value to add to the component. Defaults to 1.
    /// - Returns: A new date with the specified component and value added.
    ///
    func adding(_ component: Calendar.Component, value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: component, value: value, to: self)!
    }

    /// Returns a new date by adding a specified number of days to the current date.
    ///
    /// - Parameter value: The number of days to add. Defaults to 1.
    /// - Returns: A new date with the specified number of days added.
    ///
    func addingDay(_ value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: .day, value: value, to: self)!
    }

    /// Returns a new date by adding a specified number of hours to the current date.
    ///
    /// - Parameter value: The number of hours to add. Defaults to 1.
    /// - Returns: A new date with the specified number of hours added.
    ///
    func addingHour(_ value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: .hour, value: value, to: self)!
    }

    /// Returns a new date by adding a specified number of weeks to the current date.
    ///
    /// - Parameter value: The number of weeks to add. Defaults to 1.
    /// - Returns: A new date with the specified number of weeks added.
    ///
    func addingWeek(_ value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: .weekOfYear, value: value, to: self)!
    }

    /// Returns a new date by adding a specified number of months to the current date.
    ///
    /// - Parameter value: The number of months to add. Defaults to 1.
    /// - Returns: A new date with the specified number of months added.
    ///
    func addingMonth(_ value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: .month, value: value, to: self)!
    }

    /// Returns a new date by adding a specified number of years to the current date.
    ///
    /// - Parameter value: The number of years to add. Defaults to 1.
    /// - Returns: A new date with the specified number of years added.
    ///
    func addingYear(_ value: Int = 1) -> Date {
        Calendar.UTC.date(byAdding: .year, value: value, to: self)!
    }
}

