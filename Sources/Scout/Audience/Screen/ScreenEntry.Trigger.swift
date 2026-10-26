//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension ScreenEntry {
    struct Trigger: Command {
        let screenID: UUID
        let name: String
        let previous: String?
        let identity: Identity.Snapshot
        let date: Date

        func execute(in context: NSManagedObjectContext) throws {
            let screen = context.insert(ScreenEntry.self)
            screen.screenID = screenID
            screen.name = name
            screen.previous = previous
            screen.date = date
            try context.link(entry: screen, identity: identity, date: date)
            try context.save()
        }
    }
}
