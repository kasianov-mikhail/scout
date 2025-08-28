//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension EventObject {
    static func stub(
        name: String,
        date: Date = Date(),
        isSynced: Bool = false,
        in context: NSManagedObjectContext
    ) -> EventObject {
        let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
        let event = EventObject(entity: entity, insertInto: context)

        event.name = name
        event.date = date
        event.eventID = UUID()
        event.isSynced = isSynced
        event.userID = UUID()
        event.launchID = UUID()
        event.sessionID = UUID()

        return event
    }
}
