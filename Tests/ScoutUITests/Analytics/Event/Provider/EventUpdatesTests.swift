//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@MainActor
struct EventUpdatesTests {
    @Test("Signals read only the new range and fields until the user shows events")
    func signalsCountNewEventsIncrementally() async throws {
        let database = ChangingEventFeed()
        let provider = EventProvider()
        let (changes, continuation) = AsyncStream<Void>.makeStream()
        continuation.yield(())
        continuation.yield(())
        continuation.finish()

        await provider.observe(for: EventQuery(text: "log"), in: database, changes: { changes })

        #expect(provider.records?.map(\.name) == ["login"])
        #expect(provider.newEventCounts == [.info: 1, .error: 1])
        #expect(!provider.hasMoreNewEvents)
        #expect(provider.showsNewEventsRow)
        let reads = await database.reads
        #expect(reads.count == 3)
        let filters = EventQuery(text: "log").filters
        #expect(reads.map(\.fields) == [Event.desiredKeys, ["date", "level"], ["date", "level"]])
        #expect(reads.map(\.filters) == [filters, filters + [newerThanOrAt(1)], filters + [newerThanOrAt(2)]])
        #expect(reads.allSatisfy { $0.limit == defaultRecordPageSize })

        let applied = await provider.showNewEvents(in: database)
        #expect(applied)
        #expect(provider.newEventCounts.isEmpty)
        #expect(!provider.showsNewEventsRow)
        #expect(provider.records?.map(\.name) == ["log_error", "logout", "login"])
        #expect(await database.reads.last?.fields == Event.desiredKeys)
        #expect(await database.reads.last?.filters == filters)
        let cursor = try #require(provider.cursor)
        await provider.fetchMore(cursor: cursor, in: database)
        #expect(provider.records?.map(\.name) == ["log_error", "logout", "login", "log_debug"])
    }

    @Test("A full new-events count stops further reads until the user shows the page")
    func fullCountStopsRepeatedReads() async throws {
        let database = DatabaseStub()
        let original = Record.eventStub(name: "original", sessionID: UUID(), date: Date(timeIntervalSince1970: 1))
        for index in 0...defaultRecordPageSize {
            database.add(Record.eventStub(name: "log_\(index)", sessionID: UUID(), date: Date(timeIntervalSince1970: 2)))
        }
        let provider = EventProvider([try Event(record: original)])
        let (changes, continuation) = AsyncStream<Void>.makeStream()
        continuation.yield(())
        continuation.yield(())
        continuation.finish()

        await provider.observe(for: EventQuery(), in: database, changes: { changes })

        #expect(provider.newEventCounts == [.info: defaultRecordPageSize])
        #expect(provider.hasMoreNewEvents)
        #expect(provider.showsNewEventsRow)
        #expect(database.readCount(of: Event.recordType) == 1)
    }

    @Test("A failed reveal leaves the count available for retry")
    func failedRevealCanBeRetried() async throws {
        let database = DatabaseStub()
        let original = Record.eventStub(name: "original", sessionID: UUID(), date: Date(timeIntervalSince1970: 1))
        let latest = Record.eventStub(name: "latest", sessionID: UUID(), date: Date(timeIntervalSince1970: 2))
        database.add(original, latest)
        let provider = EventProvider([try Event(record: original)])
        await provider.observe(for: EventQuery(), in: database, changes: { AsyncStream { $0.finish() } })

        database.failure = URLError(.notConnectedToInternet)
        let failed = await provider.showNewEvents(in: database)
        #expect(!failed)
        #expect(provider.newEventCounts == [.info: 1])
        #expect(provider.showsNewEventsRow)
        #expect(provider.records?.map(\.name) == ["original"])

        database.failure = nil
        let retried = await provider.showNewEvents(in: database)
        #expect(retried)
        #expect(provider.newEventCounts.isEmpty)
        #expect(!provider.showsNewEventsRow)
        #expect(provider.records?.map(\.name) == ["latest", "original"])
    }

    private func newerThanOrAt(_ seconds: TimeInterval) -> RecordQuery.Filter {
        .init(field: "date", op: .greaterThanOrEquals, value: .date(Date(timeIntervalSince1970: seconds)))
    }
}

private actor ChangingEventFeed: RecordReader {
    private(set) var reads: [(limit: Int, fields: [String]?, filters: [RecordQuery.Filter])] = []
    private let login = Record.eventStub(name: "login", sessionID: UUID(), date: Date(timeIntervalSince1970: 1))
    private let logout = Record.eventStub(name: "logout", sessionID: UUID(), date: Date(timeIntervalSince1970: 2))
    private let error: Record = {
        var record = Record.eventStub(name: "log_error", sessionID: UUID(), date: Date(timeIntervalSince1970: 2))
        record["level"] = EventLevel.error.rawValue
        return record
    }()

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        reads.append((limit, fields, query.filters))
        switch reads.count {
        case 1:
            return RecordChunk(records: [login], cursor: nil)
        case 2:
            return RecordChunk(records: [logout, login], cursor: nil)
        case 3:
            return RecordChunk(records: [error, logout], cursor: nil)
        default:
            let older = Record.eventStub(name: "log_debug", sessionID: UUID(), date: Date(timeIntervalSince1970: 0))
            return RecordChunk(
                records: [error, logout, login],
                cursor: RecordCursor { _ in RecordChunk(records: [older], cursor: nil) }
            )
        }
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }
}
