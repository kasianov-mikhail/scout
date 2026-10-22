//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct VisitGapFold {
    private let gaps: [Date: [Int: Int]]
    private let legacyBalance: [Date: Int]

    init(gaps: [SeriesPoint], versions: [SeriesPoint], sessions: [SeriesPoint]) {
        self.gaps = gaps.reduce(into: [:]) { days, point in
            let gap = Int(point.group) ?? VisitGapEntry.cap
            days[point.date.startOfDay, default: [:]][gap, default: 0] += Int(point.value)
        }

        let stamped = Set(versions.map(\.group))

        self.legacyBalance = sessions.reduce(into: [:]) { days, point in
            let isLegacy = !stamped.contains(LifecycleKey(point.group).version ?? "")
            days[point.date.startOfDay, default: 0] += Int(point.value) * (isLegacy ? 100 - legacyPercent : -legacyPercent)
        }
    }

    func points(in range: Range<Date>) -> [ActivityPoint] {
        range.days.filter(isStamped).compactMap(point)
    }

    func unstampedSpans(in range: Range<Date>) -> [Range<Date>] {
        var spans: [Range<Date>] = []

        for day in range.days where !isStamped(day: day) {
            let upper = min(day.addingDay(), range.upperBound)

            if let last = spans.last, day <= last.upperBound.addingDay(monthWindow) {
                spans[spans.count - 1] = last.lowerBound..<upper
            } else {
                spans.append(day..<upper)
            }
        }
        return spans
    }

    func devices(in range: Range<Date>) -> Int? {
        let days = range.startingDays

        guard let last = days.last else {
            return nil
        }
        guard days.count <= monthWindow, isStamped(days: days) else {
            return nil
        }
        return users(day: last, window: days.count)
    }

    private func isStamped(day: Date) -> Bool {
        isStamped(days: (0..<monthWindow).map { day.addingDay(-$0) })
    }

    private func isStamped(days: [Date]) -> Bool {
        days.allSatisfy { gaps[$0] != nil } && days.reduce(0) { $0 + (legacyBalance[$1] ?? 0) } <= 0
    }

    private func point(day: Date) -> ActivityPoint? {
        let mau = users(day: day, window: monthWindow)

        guard mau > 0 else {
            return nil
        }

        return ActivityPoint(
            date: day.millisecondsSince1970,
            dau: users(day: day, window: 1),
            wau: users(day: day, window: 7),
            mau: mau
        )
    }

    private func users(day: Date, window: Int) -> Int {
        (0..<window).reduce(0) { total, offset in
            let visits = gaps[day.addingDay(-offset)] ?? [:]
            return total + visits.filter { $0.key >= window - offset }.values.reduce(0, +)
        }
    }
}

private let monthWindow = 30
private let legacyPercent = 1

extension Range<Date> {
    fileprivate var days: [Date] {
        Array(stride(from: lowerBound.startOfDay, to: upperBound, by: .day))
    }

    fileprivate var startingDays: [Date] {
        let start = lowerBound.startOfDay
        return Array(stride(from: start < lowerBound ? start.addingDay() : start, to: upperBound, by: .day))
    }
}
