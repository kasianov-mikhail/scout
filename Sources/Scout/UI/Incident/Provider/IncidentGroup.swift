//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol Incident: Identifiable, Comparable, SessionContext {
    var fingerprint: String { get }
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date? { get }
}

struct IncidentGroup<Element: Incident>: Identifiable {
    let records: [Element]

    var id: String {
        representative.fingerprint
    }

    var name: String {
        representative.name
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
    static func groups(from records: [Element]) -> [IncidentGroup] {
        Dictionary(grouping: records, by: \.fingerprint)
            .values
            .map { IncidentGroup(records: $0.sorted()) }
            .sorted()
    }
}

extension IncidentGroup {
    var exportSummary: String {
        var parts = [ExportFormat.counted(count, "occurrence", "occurrences")]
        if affectedDevices > 0 {
            parts.append(ExportFormat.counted(affectedDevices, "device", "devices"))
        }
        if affectedSessions > 0 {
            parts.append(ExportFormat.counted(affectedSessions, "session", "sessions"))
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
