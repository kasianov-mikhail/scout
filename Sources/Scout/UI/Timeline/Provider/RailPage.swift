//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct RailPage {
    let installID: UUID
    let eventName: String?
    let cursor: CKQueryOperation.Cursor?
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
            predicate: NSPredicate(format: "install_id == %@", installID.uuidString)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "start_date", ascending: false)
        ]
        return try await database.read(matching: query, fields: nil, limit: 10)
    }

    private func events(for sessions: [Session]) async throws -> [Event] {
        let sessionIDs = sessions.compactMap(\.sessionID).map(\.uuidString)

        guard sessionIDs.count > 0 else { return [] }

        let predicate: NSPredicate =
            if let eventName {
                NSPredicate(format: "session_id IN %@ AND name == %@", sessionIDs, eventName)
            } else {
                NSPredicate(format: "session_id IN %@", sessionIDs)
            }

        let query = CKQuery(recordType: EventObject.recordType, predicate: predicate)

        return try await database
            .readAll(matching: query, fields: nil)
            .map(Event.init)
    }
}
