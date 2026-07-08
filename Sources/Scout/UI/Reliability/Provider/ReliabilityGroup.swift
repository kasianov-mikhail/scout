//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol ReliabilityRecord: Identifiable, Comparable, SessionContext {
    var fingerprint: String { get }
    var name: String { get }
    var reason: String? { get }
    var stackTrace: [String] { get }
    var date: Date? { get }
}

struct ReliabilityGroup<Element: ReliabilityRecord>: Identifiable {
    let records: [Element]

    var id: String {
        representative.fingerprint
    }

    var name: String {
        representative.name
    }
}

extension ReliabilityGroup {
    var representative: Element {
        records[0]
    }

    var count: Int {
        records.count
    }

    var affectedDevices: Int {
        Set(records.compactMap(\.deviceID)).count
    }

    var affectedSessions: Int {
        Set(records.compactMap(\.sessionID)).count
    }

    var firstDate: Date? {
        records.compactMap(\.date).min()
    }

    var lastDate: Date? {
        records.compactMap(\.date).max()
    }
}

extension ReliabilityGroup: Comparable {
    static func < (lhs: ReliabilityGroup, rhs: ReliabilityGroup) -> Bool {
        if lhs.lastDate != rhs.lastDate {
            return (lhs.lastDate ?? .distantPast) > (rhs.lastDate ?? .distantPast)
        }
        if lhs.count != rhs.count {
            return lhs.count > rhs.count
        }
        return lhs.name < rhs.name
    }
}

extension ReliabilityGroup {
    static func groups(from records: [Element]) -> [ReliabilityGroup] {
        Dictionary(grouping: records, by: \.fingerprint)
            .values
            .map { ReliabilityGroup(records: $0.sorted()) }
            .sorted()
    }
}

extension ReliabilityGroup {
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
