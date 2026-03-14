//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Logging
import Testing

@testable import Scout

@MainActor
@Test("Logging an event") func testLogEvent() throws {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date()
    let metadata: Logger.Metadata = ["key": .string("value")]

    try log(
        "Test Event",
        level: .info,
        metadata: metadata,
        date: date,
        context: context
    )

    let fetchRequest: NSFetchRequest<EventObject> = EventObject.fetchRequest()
    let events = try context.fetch(fetchRequest)

    #expect(events.count == 1)

    let event = events[0]
    #expect(event.name == "Test Event")
    #expect(event.level == Logger.Level.info.rawValue)
    #expect(event.date == date)
    #expect(event.hour == date.startOfHour)
    #expect(event.week == date.startOfWeek)
    #expect(event.eventID != nil)
    #expect(event.userID == IDs.user)
    #expect(event.paramCount == 1)

    let paramData = try #require(event.params)
    let params = try JSONDecoder().decode([String: String].self, from: paramData)

    #expect(params["key"] == "value")
}

@MainActor
@Test("Logging an event with array metadata") func testLogArrayMetadata() throws {
    let context = NSManagedObjectContext.inMemoryContext()
    let metadata: Logger.Metadata = [
        "tags": .array([.string("a"), .string("b"), .string("c")])
    ]

    try log("Array Event", level: .info, metadata: metadata, date: Date(), context: context)

    let events = try context.fetch(EventObject.fetchRequest())
    let paramData = try #require(events.first?.params)
    let params = try JSONDecoder().decode([String: String].self, from: paramData)

    #expect(params["tags"] == "a, b, c")
}

@MainActor
@Test("Logging an event with dictionary metadata") func testLogDictionaryMetadata() throws {
    let context = NSManagedObjectContext.inMemoryContext()
    let metadata: Logger.Metadata = [
        "user": .dictionary(["name": .string("Alice"), "role": .string("admin")])
    ]

    try log("Dict Event", level: .info, metadata: metadata, date: Date(), context: context)

    let events = try context.fetch(EventObject.fetchRequest())
    let paramData = try #require(events.first?.params)
    let params = try JSONDecoder().decode([String: String].self, from: paramData)

    #expect(params["user"] == "name: Alice, role: admin")
}

@MainActor
@Test("Logging an event with nested metadata") func testLogNestedMetadata() throws {
    let context = NSManagedObjectContext.inMemoryContext()
    let metadata: Logger.Metadata = [
        "simple": .string("value"),
        "list": .array([.string("x"), .stringConvertible(42)]),
        "map": .dictionary(["key": .string("val")]),
    ]

    try log("Mixed Event", level: .info, metadata: metadata, date: Date(), context: context)

    let events = try context.fetch(EventObject.fetchRequest())
    let paramData = try #require(events.first?.params)
    let params = try JSONDecoder().decode([String: String].self, from: paramData)

    #expect(params["simple"] == "value")
    #expect(params["list"] == "x, 42")
    #expect(params["map"] == "key: val")
    #expect(events.first?.paramCount == 3)
}
