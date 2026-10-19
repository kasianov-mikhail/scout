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

enum EntityCatalog {
    static func derivedValues(for record: Record) -> [String: ScoutDB.RecordValue] {
        CatalogEntry.entries.first { $0.entity == record.recordType }?.derive(record) ?? [:]
    }

    static func assetFields(entity: String) -> [String] {
        let fields = CatalogEntry.entries.first { $0.entity == entity }?.fields ?? []
        return fields.filter { $0.type == .asset }.map(\.name)
    }

    static func fields(entity: String, names: [String]) -> [String] {
        let known = Set(CatalogEntry.entries.first { $0.entity == entity }?.fields.map(\.name) ?? [])
        return names.filter(known.contains)
    }
}
