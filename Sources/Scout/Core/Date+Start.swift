//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {

    /// Returns the start of the hour for the current date.
    ///
    /// This property calculates the date representing the start of the hour
    /// for the current date instance using the UTC calendar.
    ///
    var startOfHour: Date {
        Calendar.UTC.dateComponents([.calendar, .year, .month, .day, .hour], from: self).date!
    }

    /// Returns the start of the week for the current date.
    ///
    /// This property calculates the date representing the start of the week
    /// for the current date instance using the UTC calendar.
    ///
    var startOfWeek: Date {
        Calendar.UTC.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
