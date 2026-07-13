//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Session {
    static func fetchChunk(installIDs: [UUID], anchor: Date?, ascending: Bool, limit: Int, in database: DatabaseReader)
        async throws -> RecordChunk
    {
        var filters = [
            RecordQuery.Filter(field: "install_id", op: .in, value: .strings(installIDs.map(\.uuidString)))
        ]

        if let anchor {
            filters.append(
                RecordQuery.Filter(
                    field: "start_date", op: ascending ? .greaterThan : .lessThanOrEquals, value: .date(anchor))
            )
        }

        let query = RecordQuery(
            recordType: Session.self,
            filters: filters,
            sort: [RecordQuery.Sort(field: "start_date", ascending: ascending)]
        )

        return try await database.read(matching: query, fields: Session.desiredKeys, limit: limit)
    }
}
