//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Event {
    static func fetch(sessionIDs: [UUID], in database: RecordReader) async throws -> [Event] {
        guard !sessionIDs.isEmpty else { return [] }

        let filter = RecordQuery.Filter(field: "session_id", op: .in, value: .strings(sessionIDs.map(\.uuidString)))
        let query = RecordQuery(recordType: Event.self, filters: [filter])

        return try await database.readAll(matching: query, fields: Event.desiredKeys)
    }
}
