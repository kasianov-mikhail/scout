//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum Period: String, Identifiable {
    static let all = [Period.today, .yesterday, .week, .month, .year]
    static let sessions = [Period.week, .month, .year]

    case today
    case yesterday
    case week
    case month
    case year

    var id: Self { self }
}

extension Period {
    var title: String {
        switch self {
        case .today:
            "Today"
        case .yesterday:
            "Yesterday"
        case .week:
            "Last 7 days"
        case .month:
            "Last 30 days"
        case .year:
            "Last 365 days"
        }
    }
}

// MARK: - Chart

extension Period: ChartTimeScale {
    var horizonDate: Date {
        if case .today = self {
            today.adding(rangeComponent)
        } else {
            today
        }
    }

    var rangeComponent: Calendar.Component {
        switch self {
        case .today, .yesterday:
            .day
        case .week:
            .weekOfYear
        case .month:
            .month
        case .year:
            .year
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
}

// MARK: -

extension Period: CustomStringConvertible {
    var description: String {
        rawValue.capitalized
    }
}
