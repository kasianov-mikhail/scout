//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import HostedConnector

@Suite("Hosted access cache")
struct AccessCacheTests {
    private let clock = ManualClock()
    private let pings = PingLog()

    @Test("Back-to-back checks within five minutes ping once")
    func grant() async throws {
        let cache = AccessCache(now: { clock.now })

        try await cache.check(ping: pings.record)
        clock.advance(seconds: 299)
        try await cache.check(ping: pings.record)
        #expect(pings.count == 1)

        clock.advance(seconds: 1)
        try await cache.check(ping: pings.record)
        #expect(pings.count == 2)
    }

    @Test("A failed ping is remembered for thirty seconds")
    func denial() async throws {
        let cache = AccessCache(now: { clock.now })

        await #expect(throws: DeniedError.self) {
            try await cache.check(ping: pings.fail)
        }
        clock.advance(seconds: 29)
        await #expect(throws: DeniedError.self) {
            try await cache.check(ping: pings.record)
        }
        #expect(pings.count == 1)

        clock.advance(seconds: 1)
        try await cache.check(ping: pings.record)
        #expect(pings.count == 2)
    }

    @Test("A cancelled ping is not remembered")
    func cancellation() async throws {
        let cache = AccessCache(now: { clock.now })

        await #expect(throws: CancellationError.self) {
            try await cache.check { throw CancellationError() }
        }
        try await cache.check(ping: pings.record)

        #expect(pings.count == 1)
    }

    @Test("Invalidation makes the next check ping again")
    func invalidation() async throws {
        let cache = AccessCache(now: { clock.now })

        try await cache.check(ping: pings.record)
        await cache.invalidate()
        try await cache.check(ping: pings.record)

        #expect(pings.count == 2)
    }

    @Test("A ping that outlives an invalidation does not grant access")
    func invalidationDuringPing() async throws {
        let cache = AccessCache(now: { clock.now })

        try await cache.check {
            pings.record()
            await cache.invalidate()
        }
        try await cache.check(ping: pings.record)

        #expect(pings.count == 2)
    }

    @Test("A failed write makes the next check ping again")
    func failedWrite() async throws {
        let database = HTTPDatabase(url: URL(string: "https://127.0.0.1:1/")!, apiKey: nil)

        try await database.access.check(ping: pings.record)
        await #expect(throws: (any Error).self) {
            try await database.write(record: Record(recordType: "Event", recordID: "event"))
        }
        try await database.access.check(ping: pings.record)

        #expect(pings.count == 2)
    }
}

private final class PingLog: @unchecked Sendable {
    private let lock = NSLock()
    private var pings = 0

    var count: Int {
        lock.withLock { pings }
    }

    func record() {
        lock.withLock { pings += 1 }
    }

    func fail() throws {
        record()
        throw DeniedError()
    }
}

private final class ManualClock: @unchecked Sendable {
    private let lock = NSLock()
    private var date = Date(timeIntervalSince1970: 0)

    var now: Date {
        lock.withLock { date }
    }

    func advance(seconds: TimeInterval) {
        lock.withLock { date += seconds }
    }
}

private struct DeniedError: Error {}
