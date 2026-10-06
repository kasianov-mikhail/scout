//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension NativeDatabase: DatabaseWriter {
    func write(record: Record) async throws {
        try await write(records: [record])
    }

    func write(records: [Record]) async throws {
        let store = try await resolve()
        for (entity, group) in Dictionary(grouping: records, by: \.recordType) {
            let batch = group.map { EntityWrite(values: Self.values(for: $0), uuid: $0.recordID) }
            try await store.write(batch, entity: entity)
        }
    }

    private static func values(for record: Record) -> [String: ScoutDB.RecordValue] {
        var values = record.storeValues
        values.merge(EntityCatalog.derivedValues(for: record)) { _, derived in derived }
        return values
    }
}
