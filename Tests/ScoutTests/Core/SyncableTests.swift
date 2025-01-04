//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

@MainActor struct SyncableTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Group syncable types") func testSyncableGrouping() async throws {
        let fixedDate = Date()
        let eventEntity = NSEntityDescription.entity(forEntityName: "EventModel", in: context)!
        let event = EventModel(entity: eventEntity, insertInto: context)
        event.name = "Event"
        event.date = fixedDate
        event.hour = fixedDate
        event.week = fixedDate

        let sessionEntity = NSEntityDescription.entity(forEntityName: "Session", in: context)!
        let session = Session(entity: sessionEntity, insertInto: context)
        session.startDate = fixedDate
        session.endDate = fixedDate
        session.week = fixedDate

        let syncables: [Syncable.Type] = [EventModel.self, Session.self]
        let group = try #require(try syncables.group(in: context))

        #expect(group.records.count == 1)
    }

    @Test("Group events by name and week ") func groupEvents() async throws {
        let fixedDate = Date()
        let names = ["1", "2", "2"]

        for name in names {
            let entity = NSEntityDescription.entity(forEntityName: "EventModel", in: context)!
            let event = EventModel(entity: entity, insertInto: context)
            event.name = name
            event.date = Date()
            event.hour = fixedDate
            event.week = fixedDate
        }

        let group = try #require(try EventModel.group(in: context))

        #expect(group.records.count == 2)
        #expect(group.records.allSatisfy { $0["name"] == "2" })
    }

    @Test("Group sessions by week") func groupSessions() async throws {
        let sessionEntity = NSEntityDescription.entity(forEntityName: "Session", in: context)!

        let fixedDate = Date()
        let session = Session(entity: sessionEntity, insertInto: context)
        session.startDate = fixedDate
        session.endDate = fixedDate
        session.week = fixedDate
    
        let session2 = Session(entity: sessionEntity, insertInto: context)
        session2.startDate = fixedDate
        session2.endDate = fixedDate
        session2.week = fixedDate
    
        let group = try #require(try Session.group(in: context))
    
        #expect(group.records.count == 2)
        #expect(group.records.allSatisfy { $0["week"] as? Date == fixedDate })
    }
}
