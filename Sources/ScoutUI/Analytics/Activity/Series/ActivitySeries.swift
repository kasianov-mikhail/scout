//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ActivitySeries {
    let range: ActivityRange
    let metric: ActivityPeriod
    let now: Date

    private let series: [ActivityPeriod: [ActivityValue]]
    private let leading: [ActivityPeriod: Int]
    private let source: [Date: ActivityPoint]

    init(points: [ActivityPoint], range: ActivityRange, metric: ActivityPeriod, now: Date) {
        let source = Dictionary(points.map { (Date(millisecondsSince1970: $0.date).startOfDay, $0) }, uniquingKeysWith: { first, _ in first })
        let bounds = range.range(now: now)
        let start = bounds.lowerBound.addingDay(-1)
        let days = Array(stride(from: start, to: bounds.upperBound, by: .day))

        self.range = range
        self.metric = metric
        self.now = now
        self.source = source
        self.leading = ActivityPeriod.allCases.reduce(into: [:]) { result, period in
            result[period] = period.value(point: source[start])
        }
        self.series = ActivityPeriod.allCases.reduce(into: [:]) { result, period in
            result[period] = days.dropFirst().map { day in
                ActivityValue(date: day, value: period.value(point: source[day]))
            }
        }
    }
}

extension ActivitySeries {
    var values: [ActivityValue] {
        series[metric] ?? []
    }

    var maximum: Int {
        values.map(\.value).max() ?? 0
    }

    var stickiness: Double {
        guard let day = values.last?.date else {
            return 0
        }
        guard let point = source[day] else {
            return 0
        }
        guard point.mau > 0 else {
            return 0
        }
        return Double(point.dau) / Double(point.mau)
    }

    var stickinessLabel: String {
        String(format: "%.1f%%", stickiness * 100)
    }

    var daysPerMonthLabel: String {
        String(format: "%.1f", stickiness * 30)
    }

    var rows: [ActivityRow] {
        let maximum = maximum
        return values.enumerated().reversed().map { index, value in
            let previous = index > 0 ? values[index - 1].value : leading[metric]
            return ActivityRow(
                date: value.date,
                metric: ActivityMetric(value: value.value, previous: previous),
                fraction: maximum > 0 ? Double(value.value) / Double(maximum) : 0,
                isOldest: index == 0
            )
        }
    }

    func summary(period: ActivityPeriod) -> ActivityMetric {
        let values = series[period] ?? []
        let previous = values.dropLast().last?.value ?? leading[period]
        return ActivityMetric(value: values.last?.value ?? 0, previous: previous)
    }
}

struct ActivityValue: Identifiable {
    let date: Date
    let value: Int

    var id: Date { date }
}
