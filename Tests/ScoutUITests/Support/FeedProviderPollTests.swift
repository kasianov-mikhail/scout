//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@MainActor
@Suite("FeedProvider poll")
struct FeedProviderPollTests {
    private func makeProvider() async -> (EventProvider, DatabaseStub) {
        let database = DatabaseStub()
        database.add(
            Event.stub(name: "first").record,
            Event.stub(name: "second").record
        )

        let provider = EventProvider()
        await provider.fetchLatest(in: database)

        return (provider, database)
    }

    @Test("A poll holds the new records without touching the list")
    func holdsNewRecords() async {
        let (provider, database) = await makeProvider()
        let loaded = provider.records?.map(\.id)

        database.add(Event.stub(name: "third").record)
        await provider.fetchNewer(in: database)

        #expect(provider.records?.map(\.id) == loaded)
        #expect(provider.pending.map(\.name) == ["third"])
    }

    @Test("A poll that finds nothing new holds nothing")
    func holdsNothing() async {
        let (provider, database) = await makeProvider()

        await provider.fetchNewer(in: database)

        #expect(provider.pending.isEmpty)
    }

    @Test("A repeated poll does not duplicate what is already held")
    func dedupesPending() async {
        let (provider, database) = await makeProvider()

        database.add(Event.stub(name: "third").record)
        await provider.fetchNewer(in: database)
        await provider.fetchNewer(in: database)

        #expect(provider.pending.map(\.name) == ["third"])
    }

    @Test("Showing the held records puts them on top and keeps the loaded page")
    func showsPending() async {
        let (provider, database) = await makeProvider()

        database.add(Event.stub(name: "third").record)
        await provider.fetchNewer(in: database)
        provider.showPending()

        #expect(provider.records?.first?.name == "third")
        #expect(provider.records?.count == 3)
        #expect(provider.pending.isEmpty)
    }

    @Test("A change signal clears what the poll was holding")
    func fullRefreshClearsPending() async {
        let (provider, database) = await makeProvider()

        database.add(Event.stub(name: "third").record)
        await provider.fetchNewer(in: database)
        await provider.fetchAgain(in: database)

        #expect(provider.pending.isEmpty)
    }
}
