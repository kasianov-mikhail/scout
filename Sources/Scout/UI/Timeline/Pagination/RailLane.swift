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

    private var cursor: RecordCursor?

    /// Bumped by every reset; an in-flight load compares against it after each
    /// suspension and bails out instead of mixing a stale chunk (or a wiped
    /// cursor) into the fresh timeline.
    private var generation = 0

    /// Whether a load currently holds the cursor; concurrent `loadMore` calls
    /// wait for it instead of racing the cursor and dropping a chunk.
    private var isFetching = false

    /// Continuations of `loadMore` calls parked behind an in-flight load.
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func loadMore(in database: AppDatabase) async throws -> (sessions: [Session], events: [Event]) {
        // Snapshot before parking: a reset that lands while this call waits
        // means the chunk now belongs to a newer timeline, not this caller.
        let generation = generation

        // A stale in-flight load (e.g. from a superseded `start`) may still
        // advance the cursor; wait for it to land instead of racing it.
        while isFetching {
            await withCheckedContinuation { waiters.append($0) }
        }

        guard generation == self.generation, cursor != nil || pendingInstalls.count > 0 else {
            throw CancellationError()
        }

        isFetching = true
        isLoading = true
        defer {
            isFetching = false
            let parked = waiters
            waiters = []
            parked.forEach { $0.resume() }

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

    /// Sessions per chunk: a filtered timeline keeps only the matching events,
    /// so it needs a bigger net per round to reach the seed target without a
    /// long tail of follow-up requests.
    private var chunkLimit: Int { eventName == nil ? 25 : 100 }

    private func chunk(in database: AppDatabase) async throws -> RecordChunk {
        guard let cursor else {
            return try await Session.fetchChunk(installIDs: pendingInstalls, anchor: anchorDate, ascending: ascending, limit: chunkLimit, in: database)
        }
        return try await database.readMore(from: cursor, fields: Session.desiredKeys)
    }
}
