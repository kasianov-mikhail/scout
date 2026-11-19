//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension IncidentSummaryCard {
    static func occurrences<Element: Incident>(records: [Element], previous: [Element], range: IncidentRange, value: String, now: Date = Date()) -> Self {
        let slices = range.slices(now: now)
        var bars = [Double](repeating: 0, count: slices.count)

        for record in records {
            guard let date = record.date, let index = slices.firstIndex(where: { $0.contains(date) }) else {
                continue
            }
            bars[index] += 1
        }

        return Self(title: Element.kind.occurrencesTitle, value: value, change: percentChange(current: Double(records.count), previous: Double(previous.count)), bars: bars)
    }

    static func devices<Element: Incident>(records: [Element], previous: [Element], range: IncidentRange, value: String, now: Date = Date()) -> Self {
        let slices = range.slices(now: now)
        var devices = [Set<UUID>](repeating: [], count: slices.count)

        for record in records {
            guard let date = record.date, let deviceID = record.deviceID, let index = slices.firstIndex(where: { $0.contains(date) }) else {
                continue
            }
            devices[index].insert(deviceID)
        }

        let current = Set(records.compactMap(\.deviceID))
        let before = Set(previous.compactMap(\.deviceID))

        let bars = devices.map { Double($0.count) }
        return Self(title: "DEVICES", value: value, change: percentChange(current: Double(current.count), previous: Double(before.count)), bars: bars)
    }

    static func longest(records: [Hang], previous: [Hang], range: IncidentRange, now: Date = Date()) -> Self {
        let slices = range.slices(now: now)
        var bars = [Double](repeating: 0, count: slices.count)

        for record in records {
            guard let date = record.date, let index = slices.firstIndex(where: { $0.contains(date) }) else {
                continue
            }
            bars[index] = max(bars[index], record.duration)
        }

        let peak = records.map(\.duration).max() ?? 0
        let before = previous.map(\.duration).max() ?? 0
        return Self(title: "LONGEST", value: peak.duration, change: durationChange(current: peak, previous: before), bars: bars)
    }

    static func peak(records: [ResourceException], previous: [ResourceException], range: IncidentRange, now: Date = Date()) -> Self {
        let slices = range.slices(now: now)
        var bars = [Double](repeating: 0, count: slices.count)

        for record in records {
            guard let amount = ResourceAmount(reason: record.reason), let date = record.date, let index = slices.firstIndex(where: { $0.contains(date) }) else {
                continue
            }
            bars[index] = max(bars[index], amount.value)
        }

        let maximum = records.compactMap { ResourceAmount(reason: $0.reason) }.max { $0.value < $1.value }
        let before = previous.compactMap { ResourceAmount(reason: $0.reason) }.map(\.value).max() ?? 0
        let peak = maximum ?? ResourceAmount(value: 0, unit: "")
        let kind = records.compactMap(\.resourceKind).first
        return Self(title: kind?.peakTitle ?? "PEAK", value: peak.text, change: amountChange(peak: peak, previous: before), bars: bars)
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
