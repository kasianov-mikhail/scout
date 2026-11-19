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
    static let event = CatalogEntry(
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

    static let screen = CatalogEntry(
        entity: ScreenEntry.recordType,
        fields: [
            .init(name: "category", type: .string),
            .init(name: "previous", type: .string),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: "end_date", type: .timestamp),
            .init(name: lifecycleKey, type: .string),
        ],
        aggregates: [.count(by: lifecycleKey, at: "date")],
        derive: lifecycleKey
    )

    static let condition = CatalogEntry(
        entity: ConditionEntry.recordType,
        fields: [
            .init(name: "category", type: .string),
            .init(name: "value", type: .double),
            .init(name: "session_id", type: .string),
            .init(name: "app_version", type: .string),
            .init(name: "date", type: .timestamp),
            .init(name: lifecycleKey, type: .string),
        ],
        aggregates: [.count(by: lifecycleKey, at: "date")],
        derive: lifecycleKey
    )

    static let session = CatalogEntry(
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
            .init(name: lifecycleKey, type: .string),
            .init(name: deviceSystem, type: .string),
        ],
        aggregates: [
            .count(by: lifecycleKey, at: "start_date"),
            .count(by: "device_id", at: "start_date", parts: devicePageParts),
            .count(by: deviceSystem, at: "start_date", parts: devicePageParts),
        ],
        derive: { lifecycleKey(for: $0).merging(deviceSystem(for: $0)) { key, _ in key } }
    )

    static let visit = CatalogEntry(
        entity: VisitEntry.recordType,
        fields: [.init(name: "date", type: .timestamp)],
        aggregates: [.count(by: "device_id", at: "date", parts: devicePageParts)]
    )

    static let visitGap = CatalogEntry(
        entity: VisitGapEntry.recordType,
        fields: [
            .init(name: "date", type: .timestamp),
            .init(name: "gap", type: .string),
            .init(name: "app_version", type: .string),
        ],
        aggregates: [
            .count(by: "gap", at: "date"),
            .count(by: "app_version", at: "date"),
        ]
    )

    static let launch = CatalogEntry(
        entity: LaunchEntry.recordType,
        fields: [
            .init(name: "start_date", type: .timestamp),
            .init(name: "end_date", type: .timestamp),
        ]
    )

    static let install = CatalogEntry(
        entity: InstallEntry.recordType,
        fields: [.init(name: "date", type: .timestamp)]
    )
}
