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
struct EventProviderTests {
    @Test("fetchLatest loads events on the first call")
    func fetchLatestLoadsOnFirstCall() async throws {
        let database = DatabaseStub()
        database.add(
            Record.eventStub(name: "login", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "logout", sessionID: UUID(), date: Date())
        )

        let provider = EventProvider()
        await provider.fetchLatest(for: Event.Query(), in: database)

        #expect(provider.records?.count == 2)
        #expect(database.readCount(of: EventEntry.recordType) == 1)
    }

    @Test("fetchLatest does not duplicate events already loaded")
    func fetchLatestMergesById() async throws {
        let database = DatabaseStub()
        database.add(Record.eventStub(name: "login", sessionID: UUID(), date: Date()))

        let provider = EventProvider()
        await provider.fetchLatest(for: Event.Query(), in: database)
        await provider.fetchLatest(for: Event.Query(), in: database)

        #expect(provider.records?.count == 1)
        #expect(database.readCount(of: EventEntry.recordType) == 2)
    }
}
