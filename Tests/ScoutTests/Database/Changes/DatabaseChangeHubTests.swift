//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("DatabaseChangeHub")
struct DatabaseChangeHubTests {
    private func makeHub() -> DatabaseChangeHub {
        DatabaseChangeHub(coalescingWindow: .seconds(2), clock: ParkedClock())
    }

    @Test("A signal with no subscriber is dropped")
    func dropsWithoutSubscriber() async {
        let hub = makeHub()

        await hub.publish(DatabaseChange(backendID: "a", origin: .local))

        #expect(await hub.subscriberCount == 0)
        #expect(await hub.pendingCount == 0)
    }

    @Test("Signals inside the window merge into one emission")
    func mergesInsideWindow() async throws {
        let hub = makeHub()
        let stream = await hub.stream()
        var iterator = stream.makeAsyncIterator()

        await hub.publish(DatabaseChange(backendID: "a", origin: .local, entities: ["Event"]))
        await hub.publish(DatabaseChange(backendID: "a", origin: .remote, entities: ["Session"]))
        await hub.publish(DatabaseChange(backendID: "a", origin: .local, entities: ["Event"]))

        #expect(await hub.pendingCount == 1)

        await hub.flush()

        let change = try #require(await iterator.next())

        #expect(change.backendID == "a")
        #expect(change.origin == .remote)
        #expect(change.entities == ["Event", "Session"])
        #expect(await hub.pendingCount == 0)
    }

    @Test("Two backends emit separately so the dashboard can filter")
    func keepsBackendsApart() async throws {
        let hub = makeHub()
        let stream = await hub.stream()
        var iterator = stream.makeAsyncIterator()

        await hub.publish(DatabaseChange(backendID: "a", origin: .local))
        await hub.publish(DatabaseChange(backendID: "b", origin: .remote))

        await hub.flush()

        let first = try #require(await iterator.next())
        let second = try #require(await iterator.next())

        #expect(Set([first.backendID, second.backendID]) == ["a", "b"])
    }

    @Test("A second flush with nothing pending emits nothing")
    func flushesOnce() async {
        let hub = makeHub()
        let stream = await hub.stream()
        var iterator = stream.makeAsyncIterator()

        await hub.publish(DatabaseChange(backendID: "a", origin: .local))
        await hub.flush()
        await hub.flush()

        #expect(await iterator.next() != nil)
        #expect(await hub.pendingCount == 0)
    }
}

private struct ParkedClock: Clock {
    var now: ContinuousClock.Instant {
        ContinuousClock().now
    }

    var minimumResolution: Duration {
        .zero
    }

    func sleep(until deadline: ContinuousClock.Instant, tolerance: Duration?) async throws {
        try await Task.sleep(for: .seconds(3600))
    }
}
