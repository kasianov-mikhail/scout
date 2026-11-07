//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct IncidentSummaryCard: Identifiable {
    let title: String
    let value: String
    let change: String?
    let bars: [Double]

    var id: String {
        title
    }
}

extension IncidentSummaryCard {
    static func occurrences<Element: Incident>(records: [Element], value: String, now: Date = Date()) -> Self {
        let week = IncidentWeek(now: now)
        var bars = [Double](repeating: 0, count: week.count)
        var previous = 0.0

        for record in records {
            guard let date = record.date else {
                continue
            }
            if let index = week.index(date: date) {
                bars[index] += 1
            } else if week.previous.contains(date) {
                previous += 1
            }
        }

        return Self(title: Element.kind.occurrencesTitle, value: value, change: percentChange(current: bars.reduce(0, +), previous: previous), bars: bars)
    }

    static func devices<Element: Incident>(records: [Element], value: String, now: Date = Date()) -> Self {
        let week = IncidentWeek(now: now)
        var devices = [Set<UUID>](repeating: [], count: week.count)
        var current = Set<UUID>()
        var previous = Set<UUID>()

        for record in records {
            guard let date = record.date, let deviceID = record.deviceID else {
                continue
            }
            if let index = week.index(date: date) {
                devices[index].insert(deviceID)
                current.insert(deviceID)
            } else if week.previous.contains(date) {
                previous.insert(deviceID)
            }
        }

        let bars = devices.map { Double($0.count) }
        return Self(title: "DEVICES", value: value, change: percentChange(current: Double(current.count), previous: Double(previous.count)), bars: bars)
    }

    static func longest(records: [Hang], now: Date = Date()) -> Self {
        let week = IncidentWeek(now: now)
        var bars = [Double](repeating: 0, count: week.count)
        var previous = 0.0

        for record in records {
            guard let date = record.date else {
                continue
            }
            if let index = week.index(date: date) {
                bars[index] = max(bars[index], record.duration)
            } else if week.previous.contains(date) {
                previous = max(previous, record.duration)
            }
        }

        let peak = records.map(\.duration).max() ?? 0
        return Self(title: "LONGEST", value: peak.duration, change: durationChange(current: bars.max() ?? 0, previous: previous), bars: bars)
    }

    static func peak(records: [ResourceException], now: Date = Date()) -> Self {
        let week = IncidentWeek(now: now)
        var bars = [Double](repeating: 0, count: week.count)
        var previous = 0.0
        var maximum: ResourceAmount?

        for record in records {
            guard let amount = ResourceAmount(reason: record.reason) else {
                continue
            }
            if let current = maximum {
                if amount.value > current.value {
                    maximum = amount
                }
            } else {
                maximum = amount
            }
            guard let date = record.date else {
                continue
            }
            if let index = week.index(date: date) {
                bars[index] = max(bars[index], amount.value)
            } else if week.previous.contains(date) {
                previous = max(previous, amount.value)
            }
        }

        let peak = maximum ?? ResourceAmount(value: 0, unit: "")
        let kind = records.compactMap(\.resourceKind).first
        return Self(title: kind?.peakTitle ?? "PEAK", value: peak.text, change: amountChange(peak: peak, previous: previous), bars: bars)
    }
}

extension IncidentSummaryCard {
    private static func percentChange(current: Double, previous: Double) -> String? {
        guard previous > 0 else {
            return nil
        }
        let percent = ((current - previous) / previous * 100).rounded()
        guard percent != 0 else {
            return nil
        }
        return percent > 0 ? "+\(Int(percent))%" : "−\(Int(-percent))%"
    }

    private static func durationChange(current: Double, previous: Double) -> String? {
        guard previous > 0, current != previous else {
            return nil
        }
        let delta = current - previous
        return delta > 0 ? "+\(delta.duration)" : "−\((-delta).duration)"
    }

    private static func amountChange(peak: ResourceAmount, previous: Double) -> String? {
        guard previous > 0, peak.value != previous else {
            return nil
        }
        let delta = peak.value - previous
        let amount = ResourceAmount(value: abs(delta), unit: peak.unit)
        return delta > 0 ? "+\(amount.text)" : "−\(amount.text)"
    }
}

private struct IncidentWeek {
    let start: Date
    let end: Date
    let previous: Range<Date>
    let count = 7

    init(now: Date) {
        let today = now.startOfDay
        start = today.addingDay(-6)
        end = today.addingDay()
        previous = today.addingDay(-13)..<start
    }

    func index(date: Date) -> Int? {
        guard date >= start, date < end else {
            return nil
        }
        return min(max(Int(date.timeIntervalSince(start) / .day), 0), count - 1)
    }
}
