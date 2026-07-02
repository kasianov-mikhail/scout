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
struct FunnelProviderTests {
    @Test("fetchIfNeeded loads only events matching the step names and range")
    func fetchesMatchingEvents() async throws {
        let database = DatabaseStub()
        let range = Date(timeIntervalSinceReferenceDate: 0)..<Date(timeIntervalSinceReferenceDate: 100)
        database.add(
            Record.eventStub(name: "open", sessionID: UUID(), date: Date(timeIntervalSinceReferenceDate: 10)),
            Record.eventStub(name: "signup", sessionID: UUID(), date: Date(timeIntervalSinceReferenceDate: 20)),
            Record.eventStub(name: "other", sessionID: UUID(), date: Date(timeIntervalSinceReferenceDate: 30)),
            Record.eventStub(name: "open", sessionID: UUID(), date: Date(timeIntervalSinceReferenceDate: 200))
        )

        let provider = FunnelProvider()
        await provider.fetchIfNeeded(names: ["open", "signup"], range: range, in: database)

        let events = try provider.result?.get()
        #expect(events?.count == 2)
        #expect(events?.allSatisfy { ["open", "signup"].contains($0.name) } == true)
    }

    @Test("fetchIfNeeded skips repeated requests with the same parameters")
    func skipsRepeatedRequests() async {
        let database = DatabaseStub()
        let range = Date(timeIntervalSinceReferenceDate: 0)..<Date(timeIntervalSinceReferenceDate: 100)

        let provider = FunnelProvider()
        await provider.fetchIfNeeded(names: ["open", "signup"], range: range, in: database)
        await provider.fetchIfNeeded(names: ["open", "signup"], range: range, in: database)

        #expect(database.readCount(of: EventObject.recordType) == 1)
    }

    @Test("fetchIfNeeded refetches when the step names change")
    func refetchesOnChange() async {
        let database = DatabaseStub()
        let range = Date(timeIntervalSinceReferenceDate: 0)..<Date(timeIntervalSinceReferenceDate: 100)

        let provider = FunnelProvider()
        await provider.fetchIfNeeded(names: ["open", "signup"], range: range, in: database)
        await provider.fetchIfNeeded(names: ["open", "purchase"], range: range, in: database)

        #expect(database.readCount(of: EventObject.recordType) == 2)
    }

    @Test("refresh refetches with unchanged parameters")
    func refreshRefetches() async {
        let database = DatabaseStub()
        let range = Date(timeIntervalSinceReferenceDate: 0)..<Date(timeIntervalSinceReferenceDate: 100)

        let provider = FunnelProvider()
        await provider.fetchIfNeeded(names: ["open", "signup"], range: range, in: database)
        await provider.refresh(names: ["open", "signup"], range: range, in: database)

        #expect(database.readCount(of: EventObject.recordType) == 2)
    }
}
