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
@Suite("ResourceEntry")
struct ResourceEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the kind, value, session, and window")
    func recordCarriesResourceFields() {
        let resourceID = UUID()
        let session = SessionEntry.stub(date: date, in: context)
        let object = makeResource(resourceID: resourceID)
        object.session = session
        object.source = "metrickit"
        object.windowStart = date.addingDay(-1)

        let record = object.record

        #expect(record.recordType == "ResourceException")
        #expect(record.recordID == resourceID.uuidString)
        #expect(record["category"] == "cpu")
        #expect(record["value"] == 92.5)
        #expect(record["name"] == "CPU exception")
        #expect(record["app_version"] == "3.2.0")
        #expect(record["session_id"] == session.sessionID.uuidString)
        #expect(record["date_start"] == date.addingDay(-1))
        #expect(record["date"] == date)
    }

    @Test("A session lists its resource exceptions")
    func sessionListsResources() {
        let session = SessionEntry.stub(date: date, in: context)
        let object = makeResource(resourceID: UUID())
        object.session = session

        #expect(session.observations == [object])
    }

    private func makeResource(resourceID: UUID) -> ResourceEntry {
        let object = context.insert(ResourceEntry.self)
        object.resourceID = resourceID
        object.kind = "cpu"
        object.value = 92.5
        object.name = "CPU exception"
        object.appVersion = "3.2.0"
        object.date = date
        return object
    }
}
