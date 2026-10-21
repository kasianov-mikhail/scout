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
struct EventProviderTests {
    @Test("fetchLatest loads events on the first call")
    func fetchLatestLoadsOnFirstCall() async throws {
        let database = DatabaseStub()
        database.add(
            Record.eventStub(name: "login", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "logout", sessionID: UUID(), date: Date())
        )

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)

        #expect(provider.records?.count == 2)
        #expect(database.readCount(of: Event.recordType) == 1)
    }

    @Test("fetchLatest does not duplicate events already loaded")
    func fetchLatestMergesById() async throws {
        let database = DatabaseStub()
        database.add(Record.eventStub(name: "login", sessionID: UUID(), date: Date()))

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(), in: database)
        await provider.fetchLatest(for: EventQuery(), in: database)

        #expect(provider.records?.count == 1)
        #expect(database.readCount(of: Event.recordType) == 2)
    }

    @Test("fetchLatest ignores the search text")
    func fetchLatestIgnoresSearchText() async throws {
        let database = DatabaseStub()
        database.add(
            Record.eventStub(name: "purchase", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "login", sessionID: UUID(), date: Date())
        )

        let provider = EventProvider()
        await provider.fetchLatest(for: EventQuery(text: "pur"), in: database)

        #expect(provider.records?.map(\.name).sorted() == ["login", "purchase"])
    }
}
