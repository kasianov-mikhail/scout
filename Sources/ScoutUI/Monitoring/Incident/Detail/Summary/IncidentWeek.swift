//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct IncidentWeek {
    let start: Date
    let end: Date
    let previous: Range<Date>
    let count = 7

    init(now: Date) {
        let today = now.startOfDay
        start = today.addingDay(-6)
        end = today.addingDay()
        previous = today.addingDay(-13)..<start
    }

    func index(date: Date) -> Int? {
        guard date >= start, date < end else {
            return nil
        }
        return min(max(Int(date.timeIntervalSince(start) / .day), 0), count - 1)
    }
}
