//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// This extension provides utility methods for calculating the start of various calendar components
/// such as the hour, day, week, and month for a given date.
///
extension Date {

    /// Returns the start of the hour for the current date.
    ///
    /// This property calculates the date representing the start of the hour
    /// for the current date instance using the UTC calendar.
    ///
    var startOfHour: Date {
        Calendar.UTC.dateComponents([.calendar, .year, .month, .day, .hour], from: self).date!
    }

    /// Returns the start of the day for the current date.
    ///
    /// This property calculates the date representing the start of the day
    /// for the current date instance using the UTC calendar.
    ///
    var startOfDay: Date {
        Calendar.UTC.dateComponents([.calendar, .year, .month, .day], from: self).date!
    }

    /// Returns the start of the week for the current date.
    ///
    /// This property calculates the date representing the start of the week
    /// for the current date instance using the UTC calendar.
    ///
    var startOfWeek: Date {
        Calendar.UTC.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    /// Returns the start of the month for the current date.
    ///
    /// This property calculates the date representing the start of the month
    /// for the current date instance using the UTC calendar.
    ///
    var startOfMonth: Date {
        Calendar.UTC.dateComponents([.calendar, .year, .month], from: self).date!
    }
}
