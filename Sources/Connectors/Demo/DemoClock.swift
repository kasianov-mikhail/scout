//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoClock {
    let now: Date

    var today: Date {
        now.startOfDay
    }

    func daysAgo(_ days: Int) -> Date {
        today.addingTimeInterval(-TimeInterval(days) * .day)
    }

    var foldRange: Range<Date> {
        today.addingYear(-1).addingWeek(-1)..<today.addingDay()
    }

    func middayDaysAgo(_ days: Int) -> Date {
        daysAgo(days).addingTimeInterval(12 * 3600)
    }

    func momentDaysAgo(_ days: Int) -> Date {
        min(middayDaysAgo(days), now.addingTimeInterval(-60))
    }

    func moment(daysAgo: Int, spread: TimeInterval, after earliest: Date) -> Date {
        let ceiling = now.addingTimeInterval(-1)
        let floor = min(earliest.addingTimeInterval(30), ceiling)
        return min(max(middayDaysAgo(daysAgo).addingTimeInterval(spread), floor), ceiling)
    }

    func minutesAgo(_ minutes: Int) -> Date {
        now.addingTimeInterval(-TimeInterval(minutes) * 60)
    }
}
