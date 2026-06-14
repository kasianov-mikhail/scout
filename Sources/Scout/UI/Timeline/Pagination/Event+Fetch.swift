//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Event {
    static func fetch(sessionIDs: [UUID], name: String?, in database: AppDatabase) async throws -> [Event] {
        guard sessionIDs.count > 0 else {
            return []
        }

        let ids = sessionIDs.map(\.uuidString)
        let query = RecordQuery(recordType: EventObject.recordType, filters: filters(ids: ids, name: name))

        return
            try await database
            .readAll(matching: query, fields: Event.desiredKeys)
            .map(Event.init)
    }

    private static func filters(ids: [String], name: String?) -> [RecordFilter] {
        var filters = [RecordFilter(field: "session_id", op: .in, value: .strings(ids))]
        if let name {
            filters.append(RecordFilter(field: "name", op: .equals, value: .string(name)))
        }
        return filters
    }
}
