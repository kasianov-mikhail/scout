//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {

    /// A closed date range from the start of day one year and one week ago
    /// up to the start of tomorrow, using this calendar’s time zone.
    ///
    var queryRange: ClosedRange<Date> {
        let today = startOfDay(for: Date())
        let yearAgo = today.addingYear(-1).addingWeek(-1)
        let tomorrow = today.addingDay()
        return yearAgo...tomorrow
    }
}
