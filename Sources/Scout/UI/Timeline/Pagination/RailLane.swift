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
    var eventName: String? {
        didSet {
            generation += 1
            pendingInstalls = []
            cursor = nil
            anchorDate = nil
            isLoading = false
        }
    }

    /// Bounds session chunks to this lane's side of the anchor event, so both
    /// lanes grow strictly outward from the anchor instead of spending early
    /// chunks on sessions far past it.
    var anchorDate: Date?

    let ascending: Bool

    init(ascending: Bool) {
        self.ascending = ascending
    }

    @Published var pendingInstalls: [UUID] = []
    @Published var isLoading = false

    private var cursor: CKQueryOperation.Cursor?

    /// Bumped by every reset; an in-flight load compares against it after each
    /// suspension and bails out instead of mixing a stale chunk (or a wiped
    /// cursor) into the fresh timeline.
    private var generation = 0

    func loadMore(in database: AppDatabase) async throws -> (sessions: [Session], events: [Event]) {
        guard cursor != nil || pendingInstalls.count > 0 else {
            throw CancellationError()
        }

        let generation = generation
        isLoading = true
        defer {
            if generation == self.generation {
                isLoading = false
            }
        }

        let sessionChunk = try await chunk(in: database)

        guard generation == self.generation else {
            throw CancellationError()
        }

        let sessions =
            try sessionChunk
            .records
            .map(Session.init)

        let events = try await Event.fetch(
            sessionIDs: sessions.compactMap(\.sessionID),
            name: eventName,
            in: database
        )

        guard generation == self.generation else {
            throw CancellationError()
        }

        if let newCursor = sessionChunk.cursor {
            cursor = newCursor
        } else {
            cursor = nil
            pendingInstalls = []
        }

        return (sessions, events)
    }

    private func chunk(in database: AppDatabase) async throws -> RecordChunk {
        guard let cursor else {
            return try await Session.fetchChunk(installIDs: pendingInstalls, anchor: anchorDate, ascending: ascending, in: database)
        }
        return try await database.readMore(from: cursor, fields: nil)
    }
}
