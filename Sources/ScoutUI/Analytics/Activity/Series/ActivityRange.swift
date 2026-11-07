//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

enum ActivityRange: String, CaseIterable, Identifiable {
    case month
    case year
    case today
    case yesterday
    case week

    var id: Self { self }

    var title: String {
        switch self {
        case .month:
            "30 days"
        case .year:
            "Year"
        case .today:
            "Today"
        case .yesterday:
            "Yesterday"
        case .week:
            "7 days"
        }
    }

    var dayCount: Int {
        switch self {
        case .month:
            30
        case .year:
            365
        case .today, .yesterday:
            1
        case .week:
            7
        }
    }

    var barSpacing: CGFloat {
        switch self {
        case .year:
            0.5
        default:
            2
        }
    }

    var endLabel: String {
        self == .yesterday ? "yesterday" : "today"
    }

    func range(now: Date) -> Range<Date> {
        let today = now.startOfDay
        if dayCount == 1 {
            let day = self == .yesterday ? today.addingDay(-1) : today
            return day..<day.addingDay()
        }
        return today.addingDay(1 - dayCount)..<today.addingDay()
    }

    func axis(now: Date) -> ActivityAxis {
        let start = range(now: now).lowerBound
        let formatter = self == .year ? DateFormatter.monthYear : DateFormatter.monthDay
        let middle = dayCount > 2 ? start.addingDay((dayCount - 1) / 2) : nil
        return ActivityAxis(
            start: formatter.string(from: start),
            middle: middle.map(formatter.string(from:)),
            end: endLabel
        )
    }
}

struct ActivityAxis {
    let start: String
    let middle: String?
    let end: String
}

extension DateFormatter {
    static let monthYear = DateFormatter(format: "MMM yyyy")
}
