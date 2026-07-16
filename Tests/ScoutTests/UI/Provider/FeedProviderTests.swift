//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

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
}

private struct RefreshFailure: Error {}

private final class FailingDatabase: DatabaseReader, @unchecked Sendable {
    func lookup(recordName: String, fields: [String]?) async throws -> Record { throw RefreshFailure() }
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk { throw RefreshFailure() }
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        throw RefreshFailure()
    }
    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk { throw RefreshFailure() }
    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws
        -> [MetricSeries]
    { throw RefreshFailure() }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { throw RefreshFailure() }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { throw RefreshFailure() }
}
