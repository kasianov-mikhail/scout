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

@MainActor class SyncTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Sync with no groups") func testSyncNoGroups() async throws {
        try await sync(syncables: [EventModel.self], database: database, context: context)
        #expect(database.events.isEmpty)
    }

    @Test("Sync with one group") func testSyncOneGroup() async throws {
        createEvent(name: "event_name", in: context)

        try await sync(syncables: [EventModel.self], database: database, context: context)

        #expect(database.events.count == 1)
        #expect(database.events.first?["name"] == "event_name")
        #expect(context.registeredObjects.isEmpty)
    }

    @Test("Sync with multiple groups") func testSyncMultipleGroups() async throws {
        for i in 1...3 {
            createEvent(name: "event_name_\(i)", in: context)
        }

        try await sync(syncables: [EventModel.self], database: database, context: context)

        #expect(database.events.count == 3)
        for i in 1...3 {
            #expect(database.events.contains { $0["name"] as? String == "event_name_\(i)" })
        }
        #expect(context.registeredObjects.isEmpty)
    }

    @discardableResult func createEvent(name: String, in context: NSManagedObjectContext)
        -> EventModel
    {
        let entity = NSEntityDescription.entity(forEntityName: "EventModel", in: context)!
        let event = EventModel(entity: entity, insertInto: context)
        event.name = name
        event.hour = Date()
        event.week = Date()
        event.date = Date()
        event.uuid = UUID()
        event.level = EventLevel.info.rawValue

        return event
    }
}

