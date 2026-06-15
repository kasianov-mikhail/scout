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
    @Test("fetchIfNeeded loads events on the first call")
    func fetchIfNeededLoadsOnFirstCall() async throws {
        let database = DatabaseStub()
        database.add(
            Record.eventStub(name: "login", sessionID: UUID(), date: Date()),
            Record.eventStub(name: "logout", sessionID: UUID(), date: Date())
        )

        let provider = EventProvider()
        await provider.fetchIfNeeded(for: Event.Query(), in: database)

        #expect(provider.events?.count == 2)
        #expect(database.readCount(of: EventObject.recordType) == 1)
    }

    @Test("fetchIfNeeded does not reload once events are present")
    func fetchIfNeededSkipsWhenLoaded() async throws {
        let database = DatabaseStub()
        database.add(Record.eventStub(name: "login", sessionID: UUID(), date: Date()))

        let provider = EventProvider()
        await provider.fetchIfNeeded(for: Event.Query(), in: database)
        await provider.fetchIfNeeded(for: Event.Query(), in: database)

        #expect(database.readCount(of: EventObject.recordType) == 1)
    }
}
