//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct RailPage {
    let installID: UUID
    let range: DateInterval?
    let cursor: CKQueryOperation.Cursor?
    let limit: Int
    let database: AppDatabase

    func load() async throws -> (sessions: [Session], events: [Event], cursor: CKQueryOperation.Cursor?) {
        let chunk = try await sessions()
        let sessions = try chunk.records.map(Session.init)
        let events = try await events(for: sessions)

        return (sessions, events, chunk.cursor)
    }

    private func sessions() async throws -> RecordChunk {
        if let cursor {
            return try await database.readMore(from: cursor, fields: nil)
        }

        let query = CKQuery(
            recordType: SessionObject.recordType,
            predicate: predicate(field: "install_id", equals: installID, dateField: "start_date")
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "start_date", ascending: false)
        ]
        return try await database.read(matching: query, fields: nil, limit: limit)
    }

    private func events(for sessions: [Session]) async throws -> [Event] {
        let sessionIDs = sessions.compactMap(\.sessionID).map(\.uuidString)

        guard sessionIDs.count > 0 else { return [] }

        let query = CKQuery(
            recordType: EventObject.recordType,
            predicate: predicate(sessionIDsIn: sessionIDs, dateField: "date")
        )
        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Event.init)
    }

    private func predicate(field: String, equals id: UUID, dateField: String) -> NSPredicate {
        guard let range else {
            return NSPredicate(format: "%K == %@", field, id.uuidString)
        }
        return NSPredicate(
            format: "%K == %@ AND %K >= %@ AND %K <= %@",
            field, id.uuidString,
            dateField, range.start as NSDate,
            dateField, range.end as NSDate
        )
    }

    private func predicate(sessionIDsIn sessionIDs: [String], dateField: String) -> NSPredicate {
        guard let range else {
            return NSPredicate(format: "session_id IN %@", sessionIDs)
        }
        return NSPredicate(
            format: "session_id IN %@ AND %K >= %@ AND %K <= %@",
            sessionIDs,
            dateField, range.start as NSDate,
            dateField, range.end as NSDate
        )
    }
}
