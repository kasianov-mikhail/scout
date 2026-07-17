//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {
    package var startOfHour: Date {
        Calendar.utc.dateComponents([.calendar, .year, .month, .day, .hour], from: self).date!
    }

    package var startOfDay: Date {
        Calendar.utc.dateComponents([.calendar, .year, .month, .day], from: self).date!
    }

    package var startOfWeek: Date {
        Calendar.utc.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }

    package var startOfMonth: Date {
        Calendar.utc.dateComponents([.calendar, .year, .month], from: self).date!
    }
}
