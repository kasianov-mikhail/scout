//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Event {
    static func fetch(sessionIDs: [UUID], name: String?, in database: AppDatabase) async throws -> [Event] {
        guard sessionIDs.count > 0 else {
            return []
        }

        let ids = sessionIDs.map(\.uuidString)
        let predicate = predicate(ids: ids, name: name)
        let query = CKQuery(recordType: EventObject.recordType, predicate: predicate)

        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Event.init)
    }

    private static func predicate(ids: [String], name: String?) -> NSPredicate {
        guard let name else {
            return NSPredicate(format: "session_id IN %@", ids)
        }
        return NSPredicate(format: "session_id IN %@ AND name == %@", ids, name)
    }
}
