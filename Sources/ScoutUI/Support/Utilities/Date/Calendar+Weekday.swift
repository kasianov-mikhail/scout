//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Calendar {
    // Maps the calendar weekday (1 = Sunday … 7 = Saturday) to a Monday-based
    // index (0 = Monday … 6 = Sunday) used by the grid and calendar layouts.
    func mondayBasedWeekday(from date: Date) -> Int {
        (component(.weekday, from: date) + 5) % 7
    }
}
