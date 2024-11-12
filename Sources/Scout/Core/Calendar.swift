//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {
    
    /// A static property that returns a Calendar instance configured for UTC.
    ///
    /// This property creates a Calendar with the ISO 8601 identifier, sets the first weekday to Sunday,
    /// and configures the time zone to UTC.
    ///
    /// - Returns: A Calendar instance configured for UTC.
    ///
    static var UTC: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
