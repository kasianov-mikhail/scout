//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("Syncable+Group")
struct SyncableGroupTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Group returns records sharing the seed's batch keys")
    func testGroupByBatchKeys() throws {
        let weekA = Date(timeIntervalSince1970: 1_000_000)
        let weekB = weekA.addingWeek()

        for (name, date) in [("EventA", weekA), ("EventA", weekA), ("EventB", weekB)] {
            EventObject.stub(name: name, date: date, in: context).seedDelivery([.raw], for: "b", in: context)
        }
        try context.save()

        let batch = try #require(try EventObject.group(in: context, for: "b"))

        #expect(Set(batch.map(\.name)).count == 1)
    }

    @Test("Returns nil when nothing is owed to the backend")
    func testGroupReturnsNilWhenNoUnsynced() throws {
        EventObject.stub(name: "EventA", synced: true, in: context)
        try context.save()

        let batch = try EventObject.group(in: context, for: "b")

        #expect(batch == nil)
    }

    @Test("Group includes only objects that owe the backend work")
    func testGroupIgnoresSyncedObjects() throws {
        let week = Date()
        EventObject.stub(name: "EventC", date: week, synced: true, in: context)
        let event = EventObject.stub(name: "EventC", date: week, in: context)
        event.seedDelivery([.raw], for: "b", in: context)
        try context.save()

        let batch = try #require(try EventObject.group(in: context, for: "b"))

        #expect(batch.count == 1)
        #expect(batch.first === event)
    }
}
