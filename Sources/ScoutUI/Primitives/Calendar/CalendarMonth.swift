//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct CalendarMonth {
    let month: Date
    let calendar: Calendar

    init(containing date: Date = Date(), calendar: Calendar = .utc) {
        self.month = date.startOfMonth
        self.calendar = calendar
    }

    static let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = .utc
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let shortMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = .utc
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    var title: String { Self.monthYear.string(from: month).capitalized }
    var shortTitle: String { Self.shortMonthYear.string(from: month).uppercased() }

    struct Day: Identifiable {
        let date: Date
        let number: Int
        let isCurrentMonth: Bool
        var id: Date { date }
    }

    var weeks: [[Day]] {
        let weekday = calendar.component(.weekday, from: month)
        let leading = (weekday + 5) % 7
        let first = month.addingDay(-leading)
        let days = (0..<42).map { offset -> Day in
            let date = first.addingDay(offset)
            return Day(
                date: date,
                number: calendar.component(.day, from: date),
                isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month)
            )
        }
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<$0 + 7]) }
    }

    func isToday(_ day: Day) -> Bool { day.date == Date().startOfDay }
}
