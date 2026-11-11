//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct IncidentTile<Element: Incident>: Identifiable {
    let tally: IncidentTally
    let records: [Element]
    let symbol: String?
    let previous: Int?
    let range: Range<Date>

    var id: String {
        tally.fingerprint
    }

    var count: Int {
        tally.count
    }

    var name: String {
        tally.name
    }
}

extension IncidentTile {
    var changeLabel: String? {
        guard let previous else {
            return nil
        }
        if previous == 0 {
            return count > 0 ? "new" : "="
        }
        let delta = count - previous
        if delta == 0 {
            return "="
        }
        return delta > 0 ? "+\(delta)" : "−\(-delta)"
    }

    var isAccented: Bool {
        guard count > 0 else {
            return false
        }
        guard let previous else {
            return false
        }
        return count > previous
    }

    var subtitle: String {
        switch Element.kind {
        case .crash:
            symbol ?? lastDate?.relativeString ?? ""
        case .hang:
            hangSubtitle
        case .resource:
            symbol ?? records.first?.reason ?? lastDate?.relativeString ?? ""
        }
    }

    var bars: [Int] {
        let points = records.compactMap { record -> ChartPoint<Int>? in
            guard let date = record.date else {
                return nil
            }
            return ChartPoint(date: date, value: 1)
        }
        return MiniChartSeries(points: points, range: range, aggregation: .total).values
    }

    var todayCount: Int {
        let today = range.upperBound.addingDay(-1)
        return records.filter { ($0.date ?? .distantPast) >= today }.count
    }

    private var hangSubtitle: String {
        guard let peak = records.compactMap({ $0 as? Hang }).max(by: { $0.duration < $1.duration }) else {
            return "Hang"
        }
        return "\(peak.severity.detailLabel.capitalized) · up to \(peak.duration.duration)"
    }

    private var lastDate: Date? {
        records.compactMap(\.date).max()
    }
}

extension IncidentTile {
    static func tiles(records: [Element], legacy: [Element] = [], keys: [String: String], current: IncidentIndex?, previous: IncidentIndex?, range: Range<Date>) -> [IncidentTile] {
        let legacyIDs = Set(legacy.map(\.id))
        let loaded = Dictionary(grouping: records.filter { !legacyIDs.contains($0.id) }, by: \.fingerprint)
        let unkeyed = Dictionary(grouping: legacy, by: \.fingerprint)

        var tallies: [String: IncidentTally] = [:]
        for tally in current?.tallies ?? [] {
            tallies[tally.fingerprint] = tally
        }

        for fingerprint in Set(loaded.keys).union(unkeyed.keys) {
            let group = (loaded[fingerprint] ?? []) + (unkeyed[fingerprint] ?? [])
            let name = group.first?.name ?? ""
            guard let first = group.compactMap(\.date).min() else {
                continue
            }
            let pageCount = loaded[fingerprint]?.count ?? 0
            let legacyCount = unkeyed[fingerprint]?.count ?? 0
            if let tally = tallies[fingerprint] {
                tallies[fingerprint] = IncidentTally(
                    fingerprint: fingerprint,
                    name: tally.name.isEmpty ? name : tally.name,
                    count: max(tally.count, pageCount) + legacyCount,
                    firstHour: tally.firstHour
                )
            } else {
                tallies[fingerprint] = IncidentTally(
                    fingerprint: fingerprint,
                    name: name,
                    count: pageCount + legacyCount,
                    firstHour: first.startOfHour
                )
            }
        }

        var previousCounts: [String: Int]?
        if let previous {
            previousCounts = [:]
            for tally in previous.tallies {
                previousCounts?[tally.fingerprint] = tally.count
            }
        }

        for tally in previous?.tallies ?? [] where tallies[tally.fingerprint] == nil {
            tallies[tally.fingerprint] = IncidentTally(
                fingerprint: tally.fingerprint,
                name: tally.name,
                count: 0,
                firstHour: tally.firstHour
            )
        }

        return tallies.values.map { tally in
            let records = (loaded[tally.fingerprint] ?? []) + (unkeyed[tally.fingerprint] ?? [])
            return IncidentTile(
                tally: tally,
                records: records,
                symbol: symbol(for: records, keys: keys),
                previous: previousCounts.map { $0[tally.fingerprint] ?? 0 },
                range: range
            )
        }
        .sorted()
    }

    private static func symbol(for records: [Element], keys: [String: String]) -> String? {
        for record in records {
            guard let key = keys[record.id] else {
                continue
            }
            return key.split(separator: "|", maxSplits: 1).last.map(String.init)
        }
        return nil
    }
}

extension IncidentTile: Comparable {
    static func < (lhs: IncidentTile, rhs: IncidentTile) -> Bool {
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        if lhs.previous ?? 0 != rhs.previous ?? 0 {
            return lhs.previous ?? 0 > rhs.previous ?? 0
        }
        return lhs.name < rhs.name
    }
}
