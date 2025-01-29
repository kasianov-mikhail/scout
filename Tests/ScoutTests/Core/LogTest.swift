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

@MainActor @Test("Logging an event") func testLogEvent() throws {
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

    let fetchRequest: NSFetchRequest<EventModel> = EventModel.fetchRequest()
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
    #expect(event.sessionID == IDs.session)
    #expect(event.paramCount == 1)

    let paramData = try #require(event.params)
    let params = try JSONDecoder().decode([String: String].self, from: paramData)

    #expect(params["key"] == "value")
}
