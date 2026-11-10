//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum NetworkRange: String, CaseIterable, Identifiable {
    case today
    case yesterday
    case week
    case month
    case year

    var id: Self { self }
}

extension NetworkRange {
    var title: String {
        switch self {
        case .today:
            "Today"
        case .yesterday:
            "Yesterday"
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .year:
            "365 days"
        }
    }

    var detailTitle: String {
        self == .year ? "Year" : title
    }

    var descriptor: String {
        switch self {
        case .today:
            "today"
        case .yesterday:
            "yesterday"
        case .week:
            "in 7 days"
        case .month:
            "in 30 days"
        case .year:
            "in 365 days"
        }
    }

    var pointComponent: Calendar.Component {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month:
            .day
        case .year:
            .month
        }
    }

    var bucket: SeriesBucket {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month:
            .day
        case .year:
            .week
        }
    }

    var detailBucket: SeriesBucket {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month, .year:
            .day
        }
    }

    func range(now: Date = .now) -> Range<Date> {
        let end = now.startOfDay.addingDay()

        return switch self {
        case .today:
            now.startOfDay..<end
        case .yesterday:
            now.startOfDay.addingDay(-1)..<now.startOfDay
        case .week:
            now.startOfDay.addingDay(-6)..<end
        case .month:
            now.startOfDay.addingDay(-29)..<end
        case .year:
            now.startOfDay.addingDay(-364)..<end
        }
    }
}

extension NetworkRange: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }

    private var order: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
