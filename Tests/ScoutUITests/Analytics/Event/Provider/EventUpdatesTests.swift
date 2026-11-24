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
    @Test("Only events newer than the page are counted")
    func countsEventsNewerThanThePage() async {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let shown = Event.sample("shown", at: date, level: .info)
        let updates = EventUpdates()
        updates.recordBaseline([shown])

        let database = DatabaseStub()
        database.add(
            shown.record,
            Event.sample("old", at: date.addingTimeInterval(-60), level: .warning).record,
            Event.sample("failed", at: date.addingTimeInterval(60), level: .error).record,
            Event.sample("opened", at: date.addingTimeInterval(120), level: .info).record
        )

        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: database)

        #expect(updates.counts == [.error: 1, .info: 1])
        #expect(!updates.hasMore)
    }

    @Test("A counted event is not counted twice")
    func doesNotCountTwice() async {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let updates = EventUpdates()
        updates.recordBaseline([Event.sample("shown", at: date)])

        let database = DatabaseStub()
        database.add(Event.sample("failed", at: date.addingTimeInterval(60), level: .error).record)

        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: database)
        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: database)

        #expect(updates.counts == [.error: 1])
    }

    @Test("A full page reports that more events may exist")
    func fullPageHasMore() async {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let updates = EventUpdates()
        updates.recordBaseline([Event.sample("shown", at: date)])

        let database = DatabaseStub()
        for index in 0..<(defaultRecordPageSize + 1) {
            let level: EventLevel = index.isMultiple(of: 2) ? .error : .info
            database.add(Event.sample("event", at: date.addingTimeInterval(Double(index + 1)), level: level).record)
        }

        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: database)

        #expect(updates.counts.values.reduce(0, +) == defaultRecordPageSize)
        #expect(updates.hasMore)
    }

    @Test("An empty page counts events written after it loaded")
    func emptyPageCountsNewEvents() async {
        let updates = EventUpdates()
        updates.recordBaseline([])

        let database = DatabaseStub()
        database.add(Event.sample("failed", at: Date().addingTimeInterval(60), level: .error).record)

        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: database)

        #expect(updates.counts == [.error: 1])
    }

    @Test("Without a page nothing is counted")
    func noPageCountsNothing() async {
        let updates = EventUpdates()

        await updates.refresh(provider: EventProvider(), filter: EventQuery(), in: DatabaseStub())

        #expect(updates.counts.isEmpty)
    }
}
