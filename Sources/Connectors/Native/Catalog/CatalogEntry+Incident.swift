//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static let incidentKey = "incident_key"

    static func crashKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        guard let crash = try? Crash(record: record) else {
            return [:]
        }
        return [incidentKey: .string(IncidentKey(fingerprint: crash.fingerprint, name: crash.name).key)]
    }

    static func hangKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        guard let hang = try? Hang(record: record) else {
            return [:]
        }
        return [incidentKey: .string(IncidentKey(fingerprint: hang.fingerprint, name: hang.name).key)]
    }

    static func resourceKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        guard let resource = try? ResourceException(record: record) else {
            return [:]
        }
        return [incidentKey: .string(IncidentKey(fingerprint: resource.fingerprint, name: resource.name).key)]
    }

    static let incidentFields: [Field] = [
        .init(name: "name", type: .text),
        .init(name: "fingerprint", type: .string),
        .init(name: "reason", type: .string),
        .init(name: "stack_trace", type: .bytes),
    ]

    static let crash = CatalogEntry(
        entity: CrashEntry.recordType,
        fields: incidentFields + [
            .init(name: "threads", type: .bytes),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "date_start", type: .timestamp),
            .init(name: "source", type: .string),
            .init(name: lifecycleKey, type: .string),
            .init(name: incidentKey, type: .string),
        ],
        aggregates: [
            .count(by: lifecycleKey, at: "date"),
            .count(by: "device_id", at: "date", parts: devicePageParts),
            .count(by: incidentKey, at: "date"),
        ],
        derive: { lifecycleKey(for: $0).merging(crashKey(for: $0)) { key, _ in key } }
    )

    static let hang = CatalogEntry(
        entity: HangEntry.recordType,
        fields: incidentFields + [
            .init(name: "duration", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: lifecycleKey, type: .string),
            .init(name: incidentKey, type: .string),
        ],
        aggregates: [
            .count(by: lifecycleKey, at: "date"),
            .count(by: incidentKey, at: "date"),
        ],
        derive: { lifecycleKey(for: $0).merging(hangKey(for: $0)) { key, _ in key } }
    )

    static let resourceException = CatalogEntry(
        entity: ResourceEntry.recordType,
        fields: incidentFields + [
            .init(name: "category", type: .string),
            .init(name: "value", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "date_start", type: .timestamp),
            .init(name: "source", type: .string),
            .init(name: lifecycleKey, type: .string),
            .init(name: incidentKey, type: .string),
        ],
        aggregates: [
            .count(by: lifecycleKey, at: "date"),
            .count(by: incidentKey, at: "date"),
        ],
        derive: { lifecycleKey(for: $0).merging(resourceKey(for: $0)) { key, _ in key } }
    )

    static let backtrace = CatalogEntry(
        entity: BacktraceEntry.recordType,
        fields: [
            .init(name: "incident_id", type: .string),
            .init(name: "backtrace", type: .bytes),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    static let symbols = CatalogEntry(
        entity: BundledSymbols.indexType,
        fields: [
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    static let symbolsFile = CatalogEntry(
        entity: BundledSymbols.fileType,
        fields: [
            .init(name: "image_uuid", type: .string),
            .init(name: "file", type: .asset),
            .init(name: "date", type: .timestamp),
        ]
    )
}

struct IncidentKey: Hashable {
    let fingerprint: String
    let name: String

    var key: String {
        [fingerprint, name].joined(separator: "|")
    }
}

extension IncidentKey {
    init?(key: String) {
        let parts = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)

        guard parts.count == 2, !parts[0].isEmpty else {
            return nil
        }

        self.init(fingerprint: String(parts[0]), name: String(parts[1]))
    }
}
