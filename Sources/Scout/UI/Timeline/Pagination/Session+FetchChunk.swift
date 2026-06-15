//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Session {
    static func fetchChunk(installIDs: [UUID], anchor: Date?, ascending: Bool, limit: Int, in database: AppDatabase) async throws -> RecordChunk {
        var filters = [
            RecordFilter(field: "install_id", op: .in, value: .strings(installIDs.map(\.uuidString)))
        ]

        // The anchor session itself starts at or before the anchor event, so
        // it belongs to the descending (older) lane; the ascending lane picks
        // up strictly later sessions. Comparisons skip records that lack the
        // field, but `SessionObject.toRecord` always writes `start_date`, so
        // the bound drops nothing.
        if let anchor {
            filters.append(
                RecordFilter(field: "start_date", op: ascending ? .greaterThan : .lessThanOrEquals, value: .date(anchor))
            )
        }

        let query = RecordQuery(
            recordType: SessionObject.recordType,
            filters: filters,
            sort: [RecordSort(field: "start_date", ascending: ascending)]
        )

        return try await database.read(matching: query, fields: Session.desiredKeys, limit: limit)
    }
}
