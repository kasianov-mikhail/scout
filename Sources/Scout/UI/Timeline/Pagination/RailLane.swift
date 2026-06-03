//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation

@MainActor
final class RailLane: ObservableObject {
    let eventName: String?

    init(eventName: String? = nil) {
        self.eventName = eventName
    }

    @Published var pendingInstalls: [UUID] = []
    @Published var isLoading = false

    private var cursor: CKQueryOperation.Cursor?

    func loadMore(in database: AppDatabase) async throws -> (sessions: [Session], events: [Event]) {
        isLoading = true
        defer { isLoading = false }

        let sessionChunk = try await chunk(in: database)

        let sessions =
            try sessionChunk
            .records
            .map(Session.init)

        let events = try await Event.fetch(
            sessionIDs: sessions.compactMap(\.sessionID),
            name: eventName,
            in: database
        )

        if let newCursor = sessionChunk.cursor {
            cursor = newCursor
        } else {
            cursor = nil
            pendingInstalls.removeFirst()
        }

        return (sessions, events)
    }

    private func chunk(in database: AppDatabase) async throws -> RecordChunk {
        guard let cursor else {
            return try await Session.fetchChunk(installID: pendingInstalls[0], in: database)
        }
        return try await database.readMore(from: cursor, fields: nil)
    }
}
