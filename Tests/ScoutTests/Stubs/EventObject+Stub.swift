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
        level: EventLevel = .info,
        in context: NSManagedObjectContext
    ) -> EventObject {
        let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
        let event = EventObject(entity: entity, insertInto: context)

        event.name = name
        event.date = date
        event.eventID = UUID()
        event.isSynced = synced
        event.level = level.rawValue

        return event
    }
}
