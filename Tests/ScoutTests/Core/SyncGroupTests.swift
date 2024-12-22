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

@MainActor struct SyncGroupTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Create group from the stored events") func group() async throws {
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

        let group = try #require(try SyncGroup.group(in: context))

        #expect(group.events.count == 2)
        #expect(group.events.allSatisfy { $0.name == "2" })
    }

    @Test("Create a new matrix") func testNewMatrix() async throws {
        let group = SyncGroup(name: "group_name", week: Date(), events: [])
        let matrix = group.newMatrix()

        #expect(group.name == matrix["name"])
        #expect(group.week == matrix["date"])
    }

    @Test("Retrieve an existing matrix") func testMatrix() async throws {
        let database = InMemoryDatabase()
        let group = SyncGroup(name: "group_name", week: Date(), events: [])

        let record = CKRecord(recordType: "DateIntMatrix")
        record["name"] = group.name
        record["date"] = group.week
        database.records = [record]

        let matrix = try await group.matrix(in: database)

        #expect(group.name == matrix["name"])
        #expect(group.week == matrix["date"])
    }
}
