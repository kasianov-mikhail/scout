//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {
    package static let utc: Calendar = {
        // Gregorian, not ISO 8601: the iso8601 identifier pins firstWeekday to
        // Monday on some systems (iOS 16) and ignores the override below, so the
        // gregorian calendar is what honours a Sunday week start everywhere.
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
}
