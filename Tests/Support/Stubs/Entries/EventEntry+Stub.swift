//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension EventEntry {
    @discardableResult static func stub(
        name: String,
        date: Date = Date(),
        synced: Bool = false,
        level: EventLevel = .info,
        session: SessionEntry? = nil,
        in context: NSManagedObjectContext
    ) -> EventEntry {
        let event = context.insert(EventEntry.self)

        event.name = name
        event.date = date
        event.eventID = UUID()
        event.setSynced(synced, in: context)
        event.level = level.rawValue
        event.session = session

        return event
    }
}
