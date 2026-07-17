//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DailyCount: Equatable {
    let date: Date
    let count: Int
}

extension DailyCount {
    static func series(
        from records: [some Incident], days: Int = 14, calendar: Calendar = .current, endingOn today: Date = Date()
    ) -> [DailyCount] {
        let start = calendar.startOfDay(for: today)

        var counts: [Date: Int] = [:]
        for record in records {
            guard let date = record.date else { continue }
            counts[calendar.startOfDay(for: date), default: 0] += 1
        }

        return (0..<days).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: start) ?? start
            return DailyCount(date: day, count: counts[day] ?? 0)
        }
    }
}
