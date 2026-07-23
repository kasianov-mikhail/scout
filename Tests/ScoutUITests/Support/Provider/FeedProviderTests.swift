//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

@MainActor
struct FeedProviderTests {
    @Test("Projects fetched records into the subclass output")
    func projectsRecordsIntoGroups() async throws {
        let database = DatabaseStub()
        database.add(
            Crash.stub(fingerprint: "A").record,
            Crash.stub(fingerprint: "A").record,
            Crash.stub(fingerprint: "B").record
        )

        let provider = IncidentProvider<Crash>()
        await provider.fetchLatest(in: database)
        let groups = try #require(provider.groups)

        #expect(groups.count == 2)
        #expect(groups.contains { $0.count == 2 })
    }

    @Test("clear resets the merge base so a narrower query drops stale records")
    func clearResetsMergeBase() async throws {
        let database = DatabaseStub()
        database.add(
            Record.eventStub(name: "login", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "logout", sessionID: UUID(), date: Date())
        )

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)
        #expect(provider.records?.count == 2)

        provider.clear()
        #expect(provider.records == nil)
        #expect(provider.cursor == nil)

        await provider.fetchLatest(for: EventQuery(name: "login"), in: database)
        #expect(provider.records?.count == 1)
    }

    @Test("Keeps prior records and surfaces no error banner when a refresh fails silently")
    func keepsDataAndStaysQuietOnRefreshFailure() async throws {
        let database = DatabaseStub()
        database.add(Record.eventStub(name: "login", sessionID: UUID(), date: Date()))

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)
        #expect(provider.records?.count == 1)

        let failing = FailingDatabase()
        let succeeded = await provider.fetchLatest(for: EventQuery(), in: failing)

        #expect(succeeded == false)
        #expect(provider.records?.count == 1)
        #expect(provider.message == nil)
    }

    @Test("A cancelled reload or page load stays quiet and keeps prior records")
    func cancellationStaysQuiet() async throws {
        let database = DatabaseStub()
        database.add(Record.eventStub(name: "login", sessionID: UUID(), date: Date()))

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)
        #expect(provider.records?.count == 1)

        await provider.fetch(for: EventQuery(), in: CancellingDatabase())
        #expect(provider.records?.count == 1)

        let cursor = RecordCursor { _ in throw CancellationError() }
        await provider.fetchMore(cursor: cursor, in: database)

        #expect(provider.records?.count == 1)
        #expect(provider.message == nil)
    }

    @Test("A refresh that resurrects an exhausted cursor does not let the next fetchMore duplicate records")
    func fetchMoreStaysDedupedAfterRefreshResurrectsCursor() async throws {
        let page1 = [
            Record.eventStub(name: "a", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "b", sessionID: UUID(), date: Date()),
        ]
        let page2 = [
            Record.eventStub(name: "c", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "d", sessionID: UUID(), date: Date()),
        ]
        let database = PagingDatabase(page1: page1, page2: page2)

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)
        let firstCursor = try #require(provider.cursor)
        await provider.fetchMore(cursor: firstCursor, in: database)
        #expect(provider.cursor == nil)
        #expect(provider.records?.count == 4)

        await provider.fetchLatest(for: EventQuery(), in: database)
        let resurrected = try #require(provider.cursor)
        await provider.fetchMore(cursor: resurrected, in: database)

        let ids = try #require(provider.records).map(\.id)
        #expect(Set(ids).count == ids.count)
        #expect(ids.count == 4)
    }
}

private final class PagingDatabase: DatabaseReader, @unchecked Sendable {
    private let page1: [Record]
    private let page2: [Record]

    init(page1: [Record], page2: [Record]) {
        self.page1 = page1
        self.page2 = page2
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        let page2 = self.page2
        return RecordChunk(records: page1, cursor: RecordCursor { _ in RecordChunk(records: page2, cursor: nil) })
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await read(matching: query, fields: fields)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record { throw RecordNotFoundError() }
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] { [] }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { [] }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { [] }
}

private final class CancellingDatabase: DatabaseReader, @unchecked Sendable {
    func lookup(recordName: String, fields: [String]?) async throws -> Record { throw CancellationError() }
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk { throw CancellationError() }
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] { throw CancellationError() }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { throw CancellationError() }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { throw CancellationError() }
}

private struct RefreshFailure: Error {}

private final class FailingDatabase: DatabaseReader, @unchecked Sendable {
    func lookup(recordName: String, fields: [String]?) async throws -> Record { throw RefreshFailure() }
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk { throw RefreshFailure() }
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        throw RefreshFailure()
    }
    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk { throw RefreshFailure() }
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] { throw RefreshFailure() }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { throw RefreshFailure() }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { throw RefreshFailure() }
}
