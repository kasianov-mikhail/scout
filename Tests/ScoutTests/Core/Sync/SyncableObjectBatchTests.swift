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
@Suite("SyncableObject+Batch")
struct SyncableObjectBatchTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Batch returns correct group based on key paths")
    func testBatchByKeyPaths() throws {
        let weekA = Date(timeIntervalSince1970: 1_000_000)
        let weekB = weekA.addingWeek()

        EventObject.stub(name: "EventA", date: weekA, synced: false, in: context)
        EventObject.stub(name: "EventA", date: weekA, synced: false, in: context)
        EventObject.stub(name: "EventB", date: weekB, synced: false, in: context)

        try context.save()

        let batch = try #require(try SyncableObject.batch(
            in: context,
            matching: [\EventObject.name, \.week]
        ))

        #expect(Set(batch.map(\.name)).count == 1)
    }

    @Test("Returns nil when no unsynced objects")
    func testBatchReturnsNilWhenNoUnsynced() throws {
        EventObject.stub(name: "EventA", synced: true, in: context)
        try context.save()

        let batch = try SyncableObject.batch(
            in: context,
            matching: [\EventObject.name]
        )

        #expect(batch == nil)
    }

    @Test("Batch groups only unsynced objects")
    func testBatchIgnoresSyncedObjects() throws {
        let week = Date()
        EventObject.stub(name: "EventC", date: week, synced: true, in: context)
        let event = EventObject.stub(name: "EventC", date: week, synced: false, in: context)
        try context.save()

        let batch = try #require(try SyncableObject.batch(
            in: context,
            matching: [\EventObject.name, \.week]
        ))

        #expect(batch.count == 1)
        #expect(batch.first === event)
    }
}
