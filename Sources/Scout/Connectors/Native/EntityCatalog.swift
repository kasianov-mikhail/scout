//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

// Slot assignment follows declaration order, so the field lists below are part
// of the stored-data contract: never reorder or retype existing fields — append
// new ones in a new schema version instead.
enum EntityCatalog {
    static let eventCountView = "count"
    static let metricSeriesView = "series"
    static let metricSeriesKey = "series_key"

    static let definitions: [EntityDefinition] = [
        event, session, visit, launch, install, device, version, crash, hang,
        metric(entity: IntMetricsEntry.recordType, valueType: .int),
        metric(entity: DoubleMetricsEntry.recordType, valueType: .double),
    ]

    static func definition(for entity: String) -> EntityDefinition? {
        definitions.first { $0.entity == entity }
    }

    // Metric series are grouped by a single grid key, so the category and name
    // are packed into one field on write and split on read. Each component is
    // backslash-escaped so a "|" (or "\") inside a category or name can't be
    // mistaken for the separator and scatter points across the wrong series.
    static func seriesKey(for record: Record) -> ScoutDB.RecordValue? {
        guard record.recordType == IntMetricsEntry.recordType || record.recordType == DoubleMetricsEntry.recordType
        else {
            return nil
        }
        let category: String? = record["category"]
        let name: String? = record["name"]
        return .string(encodeSeriesKey(category: category ?? "", name: name ?? ""))
    }

    static func encodeSeriesKey(category: String, name: String) -> String {
        escape(category) + "|" + escape(name)
    }

    // Splits a series key at its unescaped separator and unescapes both halves.
    // Legacy keys carry no escape sequences, so a value without a "|" or "\" in
    // either component decodes identically to the old first-separator split.
    static func decodeSeriesKey(_ key: String) -> (category: String, name: String)? {
        var isEscaped = false
        var index = key.startIndex
        while index < key.endIndex {
            let character = key[index]
            if isEscaped {
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "|" {
                return (unescape(String(key[..<index])), unescape(String(key[key.index(after: index)...])))
            }
            index = key.index(after: index)
        }
        return nil
    }

    private static func escape(_ component: String) -> String {
        component.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "|", with: "\\|")
    }

    private static func unescape(_ escaped: String) -> String {
        var result = ""
        var isEscaped = false
        for character in escaped {
            if isEscaped {
                if character != "\\" && character != "|" {
                    result.append("\\")
                }
                result.append(character)
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else {
                result.append(character)
            }
        }
        if isEscaped {
            result.append("\\")
        }
        return result
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

    private static let visit = definition(
        entity: VisitEntry.recordType,
        fields: [("date", .timestamp)]
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

    private typealias Spec = (String, FieldType)

    private static func definition(
        entity: String, fields: [Spec], trailing: [Spec] = [], envelopeDate: String = "date",
        views: [AggregateView]? = nil
    )
        -> EntityDefinition
    {
        EntityDefinition(
            entity: entity, version: 1, fields: slotted(fields + metadata + trailing), envelopeDate: envelopeDate,
            views: views)
    }

    private static let metadata: [Spec] = [
        ("hour", .timestamp),
        ("day", .timestamp),
        ("week", .timestamp),
        ("month", .timestamp),
        ("device_id", .string),
        ("install_id", .string),
        ("launch_id", .string),
        ("version", .int),
    ]

    private static func slotted(_ specs: [Spec]) -> [FieldDefinition] {
        var next: [Pool: Int] = [:]
        return specs.map { name, type in
            let pool = pool(for: type)
            let index = next[pool, default: 0]
            next[pool] = index + 1
            return FieldDefinition(
                name: name, type: type, storage: .slot(pool, String(format: "%@_%02d", pool.rawValue, index)))
        }
    }

    private static func pool(for type: FieldType) -> Pool {
        switch type {
        case .string:
            .string
        case .text:
            .text
        case .int:
            .int
        case .double:
            .double
        case .timestamp:
            .timestamp
        case .bytes:
            .bytes
        default:
            fatalError("Unsupported field type \(type)")
        }
    }
}
