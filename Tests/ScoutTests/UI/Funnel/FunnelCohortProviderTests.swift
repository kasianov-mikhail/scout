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
struct FunnelCohortProviderTests {
    @Test("fetchIfNeeded loads only events of the requested sessions")
    func fetchesRequestedSessions() async throws {
        let database = DatabaseStub()
        let dropped = UUID()
        database.add(
            Record.eventStub(name: "open", sessionID: dropped, date: Date()),
            Record.eventStub(name: "open", sessionID: UUID(), date: Date())
        )

        let provider = FunnelCohortProvider()
        await provider.fetchIfNeeded(ids: [dropped], key: .session, in: database)

        let events = try provider.result?.get()
        #expect(events?.count == 1)
        #expect(events?.first?.sessionID == dropped)
    }

    @Test("fetchIfNeeded skips repeated calls and empty cohorts")
    func skipsRepeatsAndEmptyCohorts() async {
        let database = DatabaseStub()

        let provider = FunnelCohortProvider()
        await provider.fetchIfNeeded(ids: [], key: .session, in: database)
        #expect(database.readCount(of: EventObject.recordType) == 0)

        await provider.fetchIfNeeded(ids: [UUID()], key: .session, in: database)
        await provider.fetchIfNeeded(ids: [UUID()], key: .session, in: database)
        #expect(database.readCount(of: EventObject.recordType) == 1)
    }

    @Test("cohortEntries picks each group's latest event and keeps input order")
    func cohortEntriesPickLatestEvent() {
        let first = UUID()
        let second = UUID()
        let missing = UUID()
        let events = [
            Event.sample("open", at: Date(timeIntervalSinceReferenceDate: 0), sessionID: first),
            Event.sample("signup", at: Date(timeIntervalSinceReferenceDate: 10), sessionID: first),
            Event.sample("open", at: Date(timeIntervalSinceReferenceDate: 5), sessionID: second),
        ]

        let entries = events.cohortEntries(for: [second, first, missing], key: .session)

        #expect(entries.map(\.groupID) == [second, first, missing])
        #expect(entries.map(\.lastEvent?.name) == ["open", "signup", nil])
    }
}
