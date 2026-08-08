//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

// One entity as scout declares it: the fields it writes, the aggregates it
// reads back as series, and the derivations it applies on write. Derived fields
// live here because they compute over scout's `Record`, which a schema
// declaration cannot express.
struct CatalogEntry {
    let entity: String
    let fields: [Field]
    let aggregates: [Aggregate]
    let derive: @Sendable (Record) -> [String: ScoutDB.RecordValue]

    struct Field {
        let name: String
        let type: FieldType
    }

    enum Aggregate {
        case count(by: String, at: String)
        case sum(String, by: String, at: String)
    }

    init(
        entity: String, fields: [Field], aggregates: [Aggregate] = [],
        derive: @escaping @Sendable (Record) -> [String: ScoutDB.RecordValue] = { _ in [:] }
    ) {
        self.entity = entity
        self.fields = fields + Self.metadata
        self.aggregates = aggregates
        self.derive = derive
    }

    // Every entity carries the same tail of bucket stamps and identifiers, so
    // it is appended once here rather than repeated in every declaration.
    private static let metadata: [Field] = [
        Field(name: "hour", type: .timestamp),
        Field(name: "day", type: .timestamp),
        Field(name: "week", type: .timestamp),
        Field(name: "month", type: .timestamp),
        Field(name: "device_id", type: .string),
        Field(name: "install_id", type: .string),
        Field(name: "launch_id", type: .string),
        Field(name: "version", type: .int),
    ]
}

extension CatalogEntry {
    // Fields are declared `.ungrouped` so a creation builds no vector of its
    // own: every aggregate scout reads is named below, dated by the record's
    // own timestamp rather than by the hour the write lands in.
    func declaration(on store: EntityStore) -> SchemaBuilder {
        var builder = store.schema(entity)

        for field in fields {
            builder = builder.field(field.name, field.type, .ungrouped)
        }
        for aggregate in aggregates {
            switch aggregate {
            case .count(let group, let date):
                builder = builder.count(by: group, at: date)
            case .sum(let field, let group, let date):
                builder = builder.sum(field, by: group, at: date)
            }
        }

        return builder
    }

    // A published schema the declaration already matches is left alone: only a
    // drift in the field list is worth a new version, and aggregates join
    // rather than replace, so republishing an unchanged one buys nothing.
    func matches(_ schema: EntitySchema) -> Bool {
        guard schema.fields.count == fields.count else {
            return false
        }
        return zip(schema.fields, fields).allSatisfy {
            $0.name == $1.name && $0.type == $1.type
        }
    }
}

enum EntityCatalog {
    static let metricSeriesKey = "series_key"

    static let entries: [CatalogEntry] = [
        event, session, visit, launch, install, device, version, crash, hang,
        metric(entity: IntMetricsEntry.recordType, valueType: .int),
        metric(entity: DoubleMetricsEntry.recordType, valueType: .double),
    ]

    static func entry(for entity: String) -> CatalogEntry? {
        entries.first { $0.entity == entity }
    }

    // The writer applies every entity's declared derivations uniformly, so a new
    // computed field is a per-entity `derive` closure here rather than a special
    // case wired into the shared write path.
    static func derivedValues(for record: Record) -> [String: ScoutDB.RecordValue] {
        entry(for: record.recordType)?.derive(record) ?? [:]
    }

    // A keyset page orders by one field, and a read without a sort of its own
    // still has to walk in some order — the entity's own timestamp is the one
    // every record carries.
    static func dateField(for entity: String) -> String {
        switch entity {
        case SessionEntry.recordType, LaunchEntry.recordType:
            "start_date"
        default:
            "date"
        }
    }

    // Metric series are grouped by a single vector key, so the category and name
    // are packed into one field on write and split on read. Each component is
    // backslash-escaped so a "|" (or "\") inside a category or name can't be
    // mistaken for the separator and scatter points across the wrong series.
    private static func seriesKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        let category: String? = record["category"]
        let name: String? = record["name"]
        return [metricSeriesKey: .string(encodeSeriesKey(category: category ?? "", name: name ?? ""))]
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

    private static let event = CatalogEntry(
        entity: EventEntry.recordType,
        fields: [
            .init(name: "name", type: .text),
            .init(name: "level", type: .string),
            .init(name: "session_id", type: .string),
            .init(name: "params", type: .bytes),
            .init(name: "param_count", type: .int),
            .init(name: "date", type: .timestamp),
        ],
        aggregates: [.count(by: "name", at: "date")]
    )

    private static let session = CatalogEntry(
        entity: SessionEntry.recordType,
        fields: [
            .init(name: "start_date", type: .timestamp),
            .init(name: "end_date", type: .timestamp),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "build_number", type: .string),
            .init(name: "os_version", type: .string),
            .init(name: "locale", type: .string),
            .init(name: "channel", type: .string),
        ]
    )

    private static let visit = CatalogEntry(
        entity: VisitEntry.recordType,
        fields: [.init(name: "date", type: .timestamp)]
    )

    private static let launch = CatalogEntry(
        entity: LaunchEntry.recordType,
        fields: [
            .init(name: "start_date", type: .timestamp),
            .init(name: "end_date", type: .timestamp),
        ]
    )

    private static let install = CatalogEntry(
        entity: InstallEntry.recordType,
        fields: [.init(name: "date", type: .timestamp)]
    )

    private static let device = CatalogEntry(
        entity: DeviceEntry.recordType,
        fields: [
            .init(name: "date", type: .timestamp),
            .init(name: "model", type: .string),
        ]
    )

    private static let version = CatalogEntry(
        entity: VersionEntry.recordType,
        fields: [
            .init(name: "date", type: .timestamp),
            .init(name: "app_version", type: .string),
            .init(name: "build_number", type: .string),
        ]
    )

    private static let crash = CatalogEntry(
        entity: CrashEntry.recordType,
        fields: [
            .init(name: "name", type: .text),
            .init(name: "fingerprint", type: .string),
            .init(name: "reason", type: .string),
            .init(name: "stack_trace", type: .bytes),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static let hang = CatalogEntry(
        entity: HangEntry.recordType,
        fields: [
            .init(name: "name", type: .text),
            .init(name: "fingerprint", type: .string),
            .init(name: "reason", type: .string),
            .init(name: "stack_trace", type: .bytes),
            .init(name: "duration", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static func metric(entity: String, valueType: FieldType) -> CatalogEntry {
        CatalogEntry(
            entity: entity,
            fields: [
                .init(name: "name", type: .text),
                .init(name: "category", type: .string),
                .init(name: "session_id", type: .string),
                .init(name: metricSeriesKey, type: .string),
                .init(name: "value", type: valueType),
                .init(name: "date", type: .timestamp),
            ],
            aggregates: [.sum("value", by: metricSeriesKey, at: "date")],
            derive: seriesKey
        )
    }
}
