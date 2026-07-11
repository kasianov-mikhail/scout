//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

// Slot assignment follows declaration order, so the field lists below are part
// of the stored-data contract: never reorder or retype existing fields — append
// new ones in a new schema version instead.
enum EntityCatalog {
    static let eventCountView = "count"
    static let metricSeriesView = "series"
    static let metricSeriesKey = "series_key"

    static let definitions: [EntityDefinition] = [
        event, session, launch, install, device, version, crash, hang,
        metric(entity: IntMetricsEntry.recordType, valueType: .int),
        metric(entity: DoubleMetricsEntry.recordType, valueType: .double),
    ]

    static func definition(for entity: String) -> EntityDefinition? {
        definitions.first { $0.entity == entity }
    }

    // Metric series are grouped by a single grid key, so the category and name
    // are packed into one pipe-separated field on write and split on read.
    static func seriesKey(for record: Record) -> ScoutDB.RecordValue? {
        guard record.recordType == IntMetricsEntry.recordType || record.recordType == DoubleMetricsEntry.recordType else {
            return nil
        }
        let category: String? = record["category"]
        let name: String? = record["name"]
        return .string((category ?? "") + "|" + (name ?? ""))
    }

    private static let event = definition(
        entity: EventEntry.recordType,
        fields: [
            ("name", .text),
            ("level", .string),
            ("session_id", .string),
            ("params", .bytes),
            ("param_count", .int),
            ("date", .timestamp),
        ],
        views: [AggregateView(name: eventCountView, groupBy: "name", bucket: .hour)]
    )

    private static let session = definition(
        entity: SessionEntry.recordType,
        fields: [
            ("start_date", .timestamp),
            ("end_date", .timestamp),
            ("session_id", .string),
            ("app_version", .string),
        ],
        trailing: [
            ("build_number", .string),
            ("os_version", .string),
            ("locale", .string),
            ("channel", .string),
        ],
        envelopeDate: "start_date"
    )

    private static let launch = definition(
        entity: LaunchEntry.recordType,
        fields: [
            ("start_date", .timestamp),
            ("end_date", .timestamp),
        ],
        envelopeDate: "start_date"
    )

    private static let install = definition(
        entity: InstallEntry.recordType,
        fields: [("date", .timestamp)]
    )

    private static let device = definition(
        entity: DeviceEntry.recordType,
        fields: [("date", .timestamp)],
        trailing: [("model", .string)]
    )

    private static let version = definition(
        entity: VersionEntry.recordType,
        fields: [
            ("date", .timestamp),
            ("app_version", .string),
            ("build_number", .string),
        ]
    )

    private static let crash = definition(
        entity: CrashEntry.recordType,
        fields: [
            ("name", .text),
            ("fingerprint", .string),
            ("reason", .string),
            ("stack_trace", .bytes),
            ("session_id", .string),
            ("app_version", .string),
            ("date", .timestamp),
        ]
    )

    private static let hang = definition(
        entity: HangEntry.recordType,
        fields: [
            ("name", .text),
            ("fingerprint", .string),
            ("reason", .string),
            ("stack_trace", .bytes),
            ("duration", .double),
            ("session_id", .string),
            ("app_version", .string),
            ("date", .timestamp),
        ]
    )

    private static func metric(entity: String, valueType: FieldType) -> EntityDefinition {
        definition(
            entity: entity,
            fields: [
                ("name", .text),
                ("category", .string),
                ("session_id", .string),
                (metricSeriesKey, .string),
                ("value", valueType),
                ("date", .timestamp),
            ],
            views: [AggregateView(name: metricSeriesView, groupBy: metricSeriesKey, bucket: .hour, sum: "value")]
        )
    }

    private static func definition(entity: String, fields: [(String, FieldType)], trailing: [(String, FieldType)] = [], envelopeDate: String = "date", views: [AggregateView]? = nil)
        -> EntityDefinition
    {
        EntityDefinition(entity: entity, version: 1, fields: slotted(fields + metadata + trailing), envelopeDate: envelopeDate, views: views)
    }

    private static let metadata: [(String, FieldType)] = [
        ("hour", .timestamp),
        ("day", .timestamp),
        ("week", .timestamp),
        ("month", .timestamp),
        ("device_id", .string),
        ("install_id", .string),
        ("launch_id", .string),
        ("version", .int),
    ]

    private static func slotted(_ specs: [(String, FieldType)]) -> [FieldDefinition] {
        var next: [Pool: Int] = [:]
        return specs.map { name, type in
            let pool = pool(for: type)
            let index = next[pool, default: 0]
            next[pool] = index + 1
            return FieldDefinition(name: name, type: type, storage: .slot(pool, String(format: "%@_%02d", pool.rawValue, index)))
        }
    }

    private static func pool(for type: FieldType) -> Pool {
        switch type {
        case .string: .string
        case .text: .text
        case .int: .int
        case .double: .double
        case .timestamp: .timestamp
        case .bytes: .bytes
        default: fatalError("Unsupported field type \(type)")
        }
    }
}
