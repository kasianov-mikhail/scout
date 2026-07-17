//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

@MainActor
struct RailLaneTests {
    private let installID = UUID()
    private let launchID = UUID()
    private let sessionID = UUID()

    private func makeDatabase() -> DatabaseStub {
        let database = DatabaseStub()
        database.add(
            .sessionStub(
                sessionID: sessionID, launchID: launchID, installID: installID, startDate: TimelineFixture.baseDate),
            .eventStub(name: "e", sessionID: sessionID, date: TimelineFixture.baseDate.addingTimeInterval(10))
        )
        return database
    }

    @Test("Throws CancellationError when nothing is pending")
    func testNothingPending() async {
        let lane = RailLane(ascending: true)

        await #expect(throws: CancellationError.self) {
            try await lane.loadMore(in: DatabaseStub())
        }
    }

    @Test("Loads sessions and events for pending installs")
    func testLoadsChunk() async throws {
        let lane = RailLane(ascending: true)
        lane.pendingInstalls = [installID]

        let (sessions, events) = try await lane.loadMore(in: makeDatabase())

        #expect(sessions.map(\.sessionID) == [sessionID])
        #expect(events.map(\.name) == ["e"])
        #expect(lane.pendingInstalls.count == 0)
        #expect(!lane.isLoading)
    }

    @Test("A reset mid-flight discards the chunk")
    func testResetMidFlight() async {
        let database = makeDatabase()
        let gate = Gate()
        database.gate = gate

        let lane = RailLane(ascending: true)
        lane.pendingInstalls = [installID]

        let load = Task {
            try await lane.loadMore(in: database)
        }

        await Task.yield()
        lane.eventName = "reset"
        gate.open()

        await #expect(throws: CancellationError.self) {
            try await load.value
        }
        #expect(!lane.isLoading)
    }

    @Test("Concurrent loads are serialized instead of racing the cursor")
    func testSerializedLoads() async {
        let database = makeDatabase()
        let gate = Gate()
        database.gate = gate

        let lane = RailLane(ascending: true)
        lane.pendingInstalls = [installID]

        let first = Task {
            try await lane.loadMore(in: database)
        }
        let second = Task {
            try await lane.loadMore(in: database)
        }

        await Task.yield()
        gate.open()

        let results = [await first.result, await second.result]
        let loaded = results.compactMap { try? $0.get() }
        let cancelled = results.count { (try? $0.get()) == nil }

        // One call wins the chunk and exhausts the lane; the parked one wakes
        // up to an empty lane and bails out. A single session query proves the
        // cursor was never raced.
        #expect(loaded.count == 1)
        #expect(cancelled == 1)
        #expect(loaded[0].sessions.map(\.sessionID) == [sessionID])
        #expect(database.readCount(of: "Session") == 1)
    }
}
