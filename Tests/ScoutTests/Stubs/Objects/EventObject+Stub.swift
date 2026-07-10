//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension EventObject {
    @discardableResult static func stub(
        name: String,
        date: Date = Date(),
        synced: Bool = false,
        level: Event.Level = .info,
        session: SessionObject? = nil,
        in context: NSManagedObjectContext
    ) -> EventObject {
        let event = context.insert(EventObject.self)

        event.name = name
        event.date = date
        event.eventID = UUID()
        event.setSynced(synced, in: context)
        event.level = level.rawValue
        event.session = session

        return event
    }
}
