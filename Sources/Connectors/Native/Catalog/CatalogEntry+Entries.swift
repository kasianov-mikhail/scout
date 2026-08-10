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
    static let entries: [CatalogEntry] = [
        event, session, visit, launch, install, device, version, crash, hang,
        metric(entity: IntMetricsEntry.recordType, valueType: .int),
        metric(entity: DoubleMetricsEntry.recordType, valueType: .double),
    ]

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
                .init(name: EntityCatalog.metricSeriesKey, type: .string),
                .init(name: "value", type: valueType),
                .init(name: "date", type: .timestamp),
            ],
            aggregates: [.sum("value", by: EntityCatalog.metricSeriesKey, at: "date")],
            derive: seriesKey
        )
    }

    private static func seriesKey(for record: Record) -> [String: ScoutDB.RecordValue] {
        let category: String? = record["category"]
        let name: String? = record["name"]
        let key = EntityCatalog.encodeSeriesKey(category: category ?? "", name: name ?? "")

        return [EntityCatalog.metricSeriesKey: .string(key)]
    }
}
