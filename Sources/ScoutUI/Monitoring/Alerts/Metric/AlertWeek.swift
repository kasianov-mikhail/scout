//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct AlertWeek: Equatable {
    struct Day: Equatable {
        let date: Date
        let values: [Double?]
    }

    let start: Date
    let values: [Double]
    let end: Date
}

extension AlertWeek {
    static func weekDays(ending end: Date) -> [Date] {
        (0..<7).map { end.addingDay(-7 + $0) }
    }

    var days: [Day] {
        Self.weekDays(ending: end).map { date in
            let startIndex = Int(date.timeIntervalSince(start) / .hour)
            let cells = (0..<24).map { hour -> Double? in
                let index = startIndex + hour
                guard values.indices.contains(index) else {
                    return nil
                }
                return values[index]
            }
            return Day(date: date, values: cells)
        }
    }

    var usualRange: ClosedRange<Int>? {
        let numbers = days.flatMap { $0.values.compactMap { $0 } }
        guard numbers.count >= 24 else {
            return nil
        }
        let low = Int(quantile(numbers, 0.1).rounded())
        let high = Int(quantile(numbers, 0.9).rounded())
        return low...max(low, high)
    }

    func fireCounts(for draft: AlertDraft) -> [AlertDraft.Sensitivity: Int] {
        Dictionary(
            uniqueKeysWithValues: AlertDraft.Sensitivity.allCases.map { sensitivity in
                var variant = draft
                variant.sensitivity = sensitivity
                return (sensitivity, variant.rule.backtestFireCount(over: values))
            })
    }

    func breachGrid(for rule: AlertRule) -> [[Bool]] {
        Self.weekDays(ending: end).map { date in
            let startIndex = Int(date.timeIntervalSince(start) / .hour)
            return (0..<24).map { hour in
                let index = startIndex + hour
                guard values.indices.contains(index) else {
                    return false
                }
                return rule.condition.isBreached(by: values[index], in: reading(at: index))
            }
        }
    }

    private func reading(at index: Int) -> MetricReading {
        guard index > 0 else {
            return MetricReading(baseline: 0, recent: [])
        }
        let upper = min(index + 1, values.count)
        let lower = max(0, upper - 24)
        let baselineUpper = lower
        let baselineLower = max(0, baselineUpper - 24)
        return MetricReading(
            baseline: Array(values[baselineLower..<baselineUpper]).median ?? 0,
            recent: Array(values[lower..<upper])
        )
    }

    private func quantile(_ numbers: [Double], _ fraction: Double) -> Double {
        let sorted = numbers.sorted()
        let position = fraction * Double(sorted.count - 1)
        let lower = Int(position.rounded(.down))
        let upper = Int(position.rounded(.up))
        guard lower != upper else {
            return sorted[lower]
        }
        let weight = position - Double(lower)
        return sorted[lower] * (1 - weight) + sorted[upper] * weight
    }
}
