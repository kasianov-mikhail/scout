//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum MetricRange: String, CaseIterable, Identifiable {
    case today
    case yesterday
    case week
    case month
    case year

    var id: Self { self }
}

struct MetricAxisLabel: Equatable {
    let text: String
    let position: Double
}

extension MetricRange {
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
            "Year"
        }
    }

    var component: Calendar.Component {
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
        case .week, .month, .year:
            .day
        }
    }

    var sectionTitle: String {
        switch self {
        case .today, .yesterday:
            "PER HOUR"
        case .week, .month:
            "PER DAY"
        case .year:
            "PER MONTH"
        }
    }

    var caption: String {
        switch self {
        case .today:
            "today"
        case .yesterday:
            "yesterday"
        case .week:
            "7 days"
        case .month:
            "30 days"
        case .year:
            "year"
        }
    }

    var totalTitle: String {
        "total \(caption)"
    }

    func caption(unit: String?) -> String {
        unit.map { "\(caption) · \($0)" } ?? caption
    }

    var comparisonTitle: String {
        switch self {
        case .today:
            "vs yesterday"
        case .yesterday:
            "vs previous day"
        case .week:
            "vs previous 7 days"
        case .month:
            "vs previous 30 days"
        case .year:
            "vs previous year"
        }
    }

    var headlineComparison: String {
        switch self {
        case .today:
            "vs yesterday at this hour"
        case .yesterday, .week, .month, .year:
            comparisonTitle
        }
    }

    var previousTitle: String {
        switch self {
        case .today:
            "yesterday"
        case .yesterday:
            "previous day"
        case .week:
            "previous 7 days"
        case .month:
            "previous 30 days"
        case .year:
            "previous year"
        }
    }

    var peakNote: String {
        switch self {
        case .today, .yesterday:
            "the line is the peak of each hour"
        case .week, .month:
            "the line is the peak of each day"
        case .year:
            "the line is the peak of each month"
        }
    }
}
