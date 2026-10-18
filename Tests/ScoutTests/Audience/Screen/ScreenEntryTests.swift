//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("ScreenEntry")
struct ScreenEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the screen, its interval, and the session")
    func recordCarriesScreenFields() {
        let screenID = UUID()
        let session = SessionEntry.stub(date: date, appVersion: "3.2.0", in: context)
        let object = makeScreen(screenID: screenID)
        object.session = session
        object.previous = "Home"
        object.endDate = date.addingTimeInterval(30)

        let record = object.record

        #expect(record.recordType == "Screen")
        #expect(record.recordID == screenID.uuidString)
        #expect(record["category"] == "Feed")
        #expect(record["previous"] == "Home")
        #expect(record["date"] == date)
        #expect(record["end_date"] == date.addingTimeInterval(30))
        #expect(record["app_version"] == "3.2.0")
        #expect(record["session_id"] == session.sessionID.uuidString)
    }

    @Test("A session lists its screens and outlives an open one")
    func sessionKeepsOpenScreen() {
        let session = SessionEntry.stub(date: date, endDate: date.addingTimeInterval(60), in: context)
        let object = makeScreen(screenID: UUID())
        object.session = session

        #expect(session.children == [object])
        #expect(!object.isPurgeable)
        #expect(!session.isDeletable)
    }

    @Test("A closed screen ends at its end date")
    func closedScreenLatest() {
        let object = makeScreen(screenID: UUID())
        object.endDate = date.addingTimeInterval(30)

        #expect(object.isPurgeable)
        #expect(object.latest == date.addingTimeInterval(30))
    }

    private func makeScreen(screenID: UUID) -> ScreenEntry {
        let object = context.insert(ScreenEntry.self)
        object.screenID = screenID
        object.name = "Feed"
        object.date = date
        return object
    }
}
