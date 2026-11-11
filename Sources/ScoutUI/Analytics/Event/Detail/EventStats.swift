//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct EventStats: Equatable {
    struct Row: Equatable, Identifiable {
        let period: Period
        let count: Int
        let blue: Double
        let above: Double

        var id: Period { period }
    }

    let today: Int
    let dayFraction: Double
    let todayBlue: Double
    let todayAbove: Double
    let rows: [Row]
    let usual: Double
    let usualFraction: Double

    init(points: [ChartPoint<Int>], now: Date = Date()) {
        let calendar = Calendar.utc
        let startOfDay = calendar.startOfDay(for: now)
        let day: TimeInterval = 86_400

        func count(in range: Range<Date>) -> Int {
            points.reduce(0) { range.contains($1.date) ? $0 + $1.value : $0 }
        }

        func range(_ period: Period) -> Range<Date> {
            switch period {
            case .today:
                startOfDay..<startOfDay.addingTimeInterval(day)
            case .yesterday:
                startOfDay.addingTimeInterval(-day)..<startOfDay
            case .week, .month, .year:
                calendar.date(byAdding: period.rangeComponent, value: -1, to: startOfDay)!..<startOfDay
            }
        }

        let periods: [Period] = [.yesterday, .week, .month, .year]
        let counts = periods.map { count(in: range($0)) }
        let rates = zip(periods, counts).map { period, count in
            let span = range(period)
            let days = max(span.upperBound.timeIntervalSince(span.lowerBound) / day, 1)
            return Double(count) / days
        }

        let usual = rates.last ?? 0
        let scale = Self.niceCeiling(rates.max() ?? 0)

        let today = count(in: range(.today))
        let dayFraction = min(max(now.timeIntervalSince(startOfDay) / day, 0), 1)
        let expected = usual * dayFraction
        let unit = usual > 0 ? usual : 1

        self.today = today
        self.dayFraction = dayFraction
        self.todayBlue = min(1, min(Double(today), expected) / unit)
        self.todayAbove = min(1 - dayFraction, max(0, Double(today) - expected) / unit)
        self.usual = usual
        self.usualFraction = usual / scale
        self.rows = zip(periods, zip(counts, rates)).map { period, value in
            let (count, rate) = value
            let isYear = period == .year
            return Row(
                period: period,
                count: count,
                blue: min(rate, isYear ? rate : usual) / scale,
                above: isYear ? 0 : max(0, rate - usual) / scale
            )
        }
    }

    static func niceCeiling(_ value: Double) -> Double {
        guard value > 0 else {
            return 1
        }
        let power = pow(10, floor(log10(value)))
        return [1, 2, 4, 5, 10].map { $0 * power }.first { $0 >= value * 0.999 } ?? value
    }

    static func countLabel(_ count: Int) -> String {
        switch count {
        case 0:
            "—"
        case 100_000...:
            "\(Int((Double(count) / 1_000).rounded()))K"
        case 1_000...:
            String(format: "%.1fK", Double(count) / 1_000)
        default:
            "\(count)"
        }
    }

    static func rateLabel(_ rate: Double) -> String {
        if rate >= 10 {
            return "\(Int(rate.rounded()))"
        }
        if rate >= 1 {
            return String(format: "%.1f", rate)
        }
        guard rate > 0 else {
            return "0"
        }
        var text = String(format: "%.2f", rate)
        while text.hasSuffix("0") {
            text.removeLast()
        }
        if text.hasSuffix(".") {
            text.removeLast()
        }
        return text
    }
}
