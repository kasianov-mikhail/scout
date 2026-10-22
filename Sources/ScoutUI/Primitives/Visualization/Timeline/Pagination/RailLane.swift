//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class RailLane: ObservableObject {
    var eventName: String? {
        didSet {
            generation = Epoch()
            pendingInstalls = []
            cursor = nil
            anchorDate = nil
            isLoading = false
        }
    }

    var anchorDate: Date?

    let ascending: Bool

    init(ascending: Bool) {
        self.ascending = ascending
    }

    @Published var pendingInstalls: [UUID] = []
    @Published var isLoading = false

    private var cursor: RecordCursor?

    private var generation = Epoch()

    private var isFetching = false

    private var waiters: [CheckedContinuation<Void, Never>] = []

    func loadMore(in database: RecordReader) async throws -> (sessions: [Session], events: [Event]) {
        let generation = generation

        while isFetching {
            await withCheckedContinuation { waiters.append($0) }
        }

        guard generation == self.generation, cursor != nil || !pendingInstalls.isEmpty else {
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

    private var chunkLimit: Int { eventName == nil ? 25 : 100 }

    private func chunk(in database: RecordReader) async throws -> RecordChunk {
        guard let cursor else {
            return try await Session.fetchChunk(
                installIDs: pendingInstalls, anchor: anchorDate, ascending: ascending, limit: chunkLimit, in: database)
        }
        return try await cursor.next(Session.desiredKeys)
    }
}
