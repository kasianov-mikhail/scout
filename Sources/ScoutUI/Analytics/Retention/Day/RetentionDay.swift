//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum RetentionDay: Int, CaseIterable, Identifiable {
    case day1 = 1
    case day3 = 3
    case day7 = 7
    case day14 = 14
    case day30 = 30

    static let tabs: [RetentionDay] = [.day1, .day7, .day30]

    var id: Int { rawValue }

    var title: String { "Day \(rawValue)" }
}

extension RetentionDay {
    func pendingDays(week: Date, now: Date) -> Int? {
        let available = week.addingDay(7 + rawValue)
        guard available > now else {
            return nil
        }
        let days = Calendar.utc.dateComponents([.day], from: now.startOfDay, to: available).day ?? 0
        return max(days, 1)
    }

    func pendingLabel(week: Date, now: Date) -> String? {
        guard let days = pendingDays(week: week, now: now) else {
            return nil
        }
        return "in \(days) d"
    }
}
