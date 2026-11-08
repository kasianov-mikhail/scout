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

    func range(now: Date) -> Range<Date> {
        let day = now.startOfDay

        return switch self {
        case .today:
            day..<day.addingDay()
        case .yesterday:
            day.addingDay(-1)..<day
        case .week:
            day.addingDay(-6)..<day.addingDay()
        case .month:
            day.addingDay(-29)..<day.addingDay()
        case .year:
            day.startOfMonth.addingMonth(-11)..<day.startOfMonth.addingMonth()
        }
    }

    func elapsedRange(now: Date) -> Range<Date> {
        let range = range(now: now)
        return range.lowerBound..<min(max(now, range.lowerBound), range.upperBound)
    }

    func elapsedPreviousRange(now: Date) -> Range<Date> {
        shifted(elapsedRange(now: now))
    }

    func buckets(now: Date) -> [Range<Date>] {
        let range = range(now: now)
        var buckets: [Range<Date>] = []
        var start = range.lowerBound

        while start < range.upperBound {
            let end = start.adding(component)
            buckets.append(start..<min(end, range.upperBound))
            start = end
        }

        return buckets
    }

    func shifted(_ range: Range<Date>) -> Range<Date> {
        switch self {
        case .today, .yesterday:
            range.lowerBound.addingDay(-1)..<range.upperBound.addingDay(-1)
        case .week:
            range.lowerBound.addingDay(-7)..<range.upperBound.addingDay(-7)
        case .month:
            range.lowerBound.addingDay(-30)..<range.upperBound.addingDay(-30)
        case .year:
            range.lowerBound.addingMonth(-12)..<range.upperBound.addingMonth(-12)
        }
    }

    func isCurrent(date: Date, now: Date) -> Bool {
        guard self != .yesterday else {
            return false
        }

        return switch component {
        case .hour:
            date == now.startOfHour
        case .day:
            date == now.startOfDay
        case .month:
            date == now.startOfMonth
        default:
            false
        }
    }

    func isFuture(date: Date, now: Date) -> Bool {
        switch component {
        case .hour:
            date > now.startOfHour
        case .day:
            date > now.startOfDay
        case .month:
            date > now.startOfMonth
        default:
            false
        }
    }

    func rowLabel(date: Date) -> String {
        switch self {
        case .today, .yesterday:
            DateFormatter.metricHour.string(from: date)
        case .week, .month:
            DateFormatter.metricDay.string(from: date)
        case .year:
            DateFormatter.monthShort.string(from: date)
        }
    }

    func axisLabels(now: Date) -> [String] {
        let buckets = buckets(now: now)

        return switch self {
        case .today, .yesterday:
            ["00:00", "06:00", "12:00", "18:00", "24:00"]
        case .week:
            [0, 2, 4, 6].compactMap { index in
                buckets.indices.contains(index) ? DateFormatter.weekdayShort.string(from: buckets[index].lowerBound) : nil
            }
        case .month:
            [0, 7, 14, 21, 29].compactMap { index in
                buckets.indices.contains(index) ? DateFormatter.monthDayShort.string(from: buckets[index].lowerBound) : nil
            }
        case .year:
            [0, 2, 4, 6, 8, 10].compactMap { index in
                buckets.indices.contains(index) ? DateFormatter.monthShort.string(from: buckets[index].lowerBound) : nil
            }
        }
    }
}

extension DateFormatter {
    static let metricHour = DateFormatter(format: "HH:00")
    static let metricDay = DateFormatter(format: "EEE d")
    static let weekdayShort = DateFormatter(format: "EEE")
    static let monthDayShort = DateFormatter(format: "MMM d")
    static let monthShort = DateFormatter(format: "MMM")
}
