//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension MetricRange {
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

    func slices(now: Date, count: Int) -> [Range<Date>] {
        let buckets = buckets(now: now)
        let upperBound = elapsedRange(now: now).upperBound

        guard buckets.count > count else {
            return buckets.filter { $0.lowerBound < upperBound }
        }

        let size = buckets.count / count
        let extra = buckets.count % count
        var slices: [Range<Date>] = []
        var start = 0

        for position in 0..<count {
            let length = size + (position < extra ? 1 : 0)
            let lowerBound = buckets[start].lowerBound
            let slice = lowerBound..<buckets[start + length - 1].upperBound

            if lowerBound < upperBound {
                slices.append(slice)
            }
            start += length
        }

        return slices
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

    func axisLabels(now: Date) -> [MetricAxisLabel] {
        let buckets = buckets(now: now)

        return switch self {
        case .today, .yesterday:
            [
                MetricAxisLabel(text: "00:00", position: 0),
                MetricAxisLabel(text: "06:00", position: 0.25),
                MetricAxisLabel(text: "12:00", position: 0.5),
                MetricAxisLabel(text: "18:00", position: 0.75),
                MetricAxisLabel(text: "24:00", position: 1),
            ]
        case .week:
            axisLabels(buckets: buckets, indices: [0, 2, 4, 6], formatter: .weekdayShort)
        case .month:
            axisLabels(buckets: buckets, indices: [0, 7, 14, 21, 29], formatter: .monthDayShort)
        case .year:
            axisLabels(buckets: buckets, indices: [0, 2, 4, 6, 8, 10], formatter: .monthShort)
        }
    }

    private func axisLabels(buckets: [Range<Date>], indices: [Int], formatter: DateFormatter) -> [MetricAxisLabel] {
        let count = Double(buckets.count)

        return indices.compactMap { index in
            guard buckets.indices.contains(index) else {
                return nil
            }

            return MetricAxisLabel(
                text: formatter.string(from: buckets[index].lowerBound),
                position: (Double(index) + 0.5) / count
            )
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
