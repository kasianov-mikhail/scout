//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

extension CatalogEntry {
    static let entries: [CatalogEntry] = [
        event, screen, condition, session, visit, launch, install, device, version, crash, hang, resourceException, backtrace, symbols, symbolsFile, dailyMetric, intMetric, doubleMetric,
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

    private static let screen = CatalogEntry(
        entity: ScreenEntry.recordType,
        fields: [
            .init(name: "category", type: .string),
            .init(name: "previous", type: .string),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "end_date", type: .timestamp),
        ]
    )

    private static let condition = CatalogEntry(
        entity: ConditionEntry.recordType,
        fields: [
            .init(name: "category", type: .string),
            .init(name: "value", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
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

    private static let incidentFields: [Field] = [
        .init(name: "name", type: .text),
        .init(name: "fingerprint", type: .string),
        .init(name: "reason", type: .string),
        .init(name: "stack_trace", type: .bytes),
    ]

    private static let crash = CatalogEntry(
        entity: CrashEntry.recordType,
        fields: incidentFields + [
            .init(name: "threads", type: .bytes),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "date_start", type: .timestamp),
            .init(name: "source", type: .string),
        ]
    )

    private static let hang = CatalogEntry(
        entity: HangEntry.recordType,
        fields: incidentFields + [
            .init(name: "duration", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static let resourceException = CatalogEntry(
        entity: ResourceEntry.recordType,
        fields: incidentFields + [
            .init(name: "category", type: .string),
            .init(name: "value", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "date_start", type: .timestamp),
            .init(name: "source", type: .string),
        ]
    )

    private static let backtrace = CatalogEntry(
        entity: BacktraceEntry.recordType,
        fields: [
            .init(name: "incident_id", type: .string),
            .init(name: "backtrace", type: .bytes),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static let symbols = CatalogEntry(
        entity: BundledSymbols.indexType,
        fields: [
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static let symbolsFile = CatalogEntry(
        entity: BundledSymbols.fileType,
        fields: [
            .init(name: "image_uuid", type: .string),
            .init(name: "file", type: .asset),
            .init(name: "date", type: .timestamp),
        ]
    )

    private static let dailyMetric = CatalogEntry(
        entity: DailyMetricEntry.recordType,
        fields: [
            .init(name: "name", type: .string),
            .init(name: "category", type: .string),
            .init(name: "value", type: .int),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "date_start", type: .timestamp),
        ]
    )
}
