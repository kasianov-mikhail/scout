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

    var name: String {
        representative.name
    }
}

extension IncidentGroup {
    init(records: [Element]) {
        self.init(id: records[0].fingerprint, records: records, symbol: nil)
    }
}

extension IncidentGroup {
    var representative: Element {
        records[0]
    }

    var count: Int {
        records.count
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

    var firstDate: Date? {
        records.compactMap(\.date).min()
    }

    var lastDate: Date? {
        records.compactMap(\.date).max()
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
    static func groups(from records: [Element], keys: [Element.ID: String] = [:]) -> [IncidentGroup] {
        let symbolicated = Set(keys.values)
        return Dictionary(grouping: records) { keys[$0.id] ?? $0.fingerprint }
            .map { key, records in
                IncidentGroup(id: key, records: records.sorted(), symbol: symbolicated.contains(key) ? key.symbolName : nil)
            }
            .sorted()
    }
}

extension IncidentGroup {
    var exportSummary: String {
        var parts = [ExportFormat.counted(count, .occurrence)]
        if affectedDevices > 0 {
            parts.append(ExportFormat.counted(affectedDevices, .device))
        }
        if affectedSessions > 0 {
            parts.append(ExportFormat.counted(affectedSessions, .session))
        }
        return parts.joined(separator: " · ")
    }

    var exportSeenLine: String? {
        guard let first = firstDate, let last = lastDate else {
            return nil
        }
        return "First seen \(ExportFormat.minute(first)) · Last seen \(ExportFormat.minute(last))"
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
