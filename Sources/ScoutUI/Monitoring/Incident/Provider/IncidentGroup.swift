//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol Incident: Identifiable, Comparable, SessionContext where ID == String {
    static var kind: IncidentKind { get }

    var fingerprint: String { get }
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date? { get }
}

extension Crash: Incident {
    static let kind = IncidentKind.crash
}

extension Hang: Incident {
    static let kind = IncidentKind.hang
}

extension ResourceException: Incident {
    static let kind = IncidentKind.resource
}

struct IncidentGroup<Element: Incident>: Identifiable {
    let id: String
    let records: [Element]
    let symbol: String?
    let count: Int
    let firstDate: Date?
    let isPartial: Bool

    var name: String {
        representative.name
    }
}

extension IncidentGroup {
    init(records: [Element]) {
        self.init(id: records[0].fingerprint, records: records, symbol: nil)
    }

    init(id: String, records: [Element], symbol: String?) {
        self.init(id: id, records: records, symbol: symbol, tallies: [:], hasMore: false)
    }

    init(id: String, records: [Element], symbol: String?, tallies: [String: IncidentTally], hasMore: Bool) {
        var count = 0
        var hours: [Date] = []
        var isPartial = false

        for (fingerprint, loaded) in Dictionary(grouping: records, by: \.fingerprint) {
            if let tally = tallies[fingerprint] {
                count += max(tally.count, loaded.count)
                hours.append(tally.firstHour)
            } else {
                count += loaded.count
                isPartial = isPartial || hasMore
            }
        }

        self.init(
            id: id,
            records: records,
            symbol: symbol,
            count: count,
            firstDate: Self.firstDate(loaded: records.compactMap(\.date).min(), firstHour: hours.min()),
            isPartial: isPartial
        )
    }

    private static func firstDate(loaded: Date?, firstHour: Date?) -> Date? {
        guard let firstHour else {
            return loaded
        }
        guard let loaded, loaded < firstHour.addingTimeInterval(.hour) else {
            return firstHour
        }
        return loaded
    }

    func replacing(records: [Element]) -> IncidentGroup {
        IncidentGroup(id: id, records: records, symbol: symbol, count: count, firstDate: firstDate, isPartial: isPartial)
    }
}

extension IncidentGroup {
    var representative: Element {
        records[0]
    }

    var deviceIDs: [UUID] {
        Array(Set(records.compactMap(\.deviceID)))
    }

    var sessionIDs: [UUID] {
        Array(Set(records.compactMap(\.sessionID)))
    }

    var affectedDevices: Int {
        deviceIDs.count
    }

    var affectedSessions: Int {
        sessionIDs.count
    }

    var lastDate: Date? {
        records.compactMap(\.date).max()
    }

    var hasAllRecords: Bool {
        !isPartial && records.count >= count
    }
}

extension IncidentGroup {
    var countSuffix: String {
        isPartial ? "+" : ""
    }

    var occurrencesText: String {
        "\(count)\(countSuffix)"
    }

    var devicesText: String {
        hasAllRecords ? "\(affectedDevices)" : "\(affectedDevices)+"
    }

    var sessionsText: String {
        hasAllRecords ? "\(affectedSessions)" : "\(affectedSessions)+"
    }

    var firstSeenLabel: String {
        isPartial ? "Earliest loaded" : "First seen"
    }
}

extension IncidentGroup: Comparable {
    static func < (lhs: IncidentGroup, rhs: IncidentGroup) -> Bool {
        if lhs.lastDate != rhs.lastDate {
            return (lhs.lastDate ?? .distantPast) > (rhs.lastDate ?? .distantPast)
        }
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        return lhs.name < rhs.name
    }
}

extension IncidentGroup {
    static func groups(from records: [Element], keys: [Element.ID: String] = [:], tallies: [String: IncidentTally] = [:], hasMore: Bool = false) -> [IncidentGroup] {
        let symbolicated = Set(keys.values)
        let grouped = Dictionary(grouping: records) { keys[$0.id] ?? $0.fingerprint }

        var owners: [String: Set<String>] = [:]
        for (key, records) in grouped {
            for record in records {
                owners[record.fingerprint, default: []].insert(key)
            }
        }
        let owned = tallies.filter { owners[$0.key]?.count == 1 }

        return
            grouped
            .map { key, records in
                IncidentGroup(
                    id: key,
                    records: records.sorted(),
                    symbol: symbolicated.contains(key) ? key.symbolName : nil,
                    tallies: owned,
                    hasMore: hasMore
                )
            }
            .sorted()
    }
}

extension IncidentGroup {
    var exportSummary: String {
        var parts = [Self.counted(count: count, noun: .occurrence, isExact: !isPartial)]
        if affectedDevices > 0 {
            parts.append(Self.counted(count: affectedDevices, noun: .device, isExact: hasAllRecords))
        }
        if affectedSessions > 0 {
            parts.append(Self.counted(count: affectedSessions, noun: .session, isExact: hasAllRecords))
        }
        return parts.joined(separator: " · ")
    }

    var exportSeenLine: String? {
        guard let first = firstDate, let last = lastDate else {
            return nil
        }
        return "\(firstSeenLabel) \(ExportFormat.minute(first)) · Last seen \(ExportFormat.minute(last))"
    }

    private static func counted(count: Int, noun: ExportFormat.Noun, isExact: Bool) -> String {
        isExact ? ExportFormat.counted(count, noun) : "\(count)+ \(noun.plural)"
    }

    var exportTopFrame: String? {
        representative.stackTrace.first { !$0.isEmpty }
    }
}

extension String {
    fileprivate var symbolName: String? {
        split(separator: "|", maxSplits: 1).last.map(String.init)
    }
}
