//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionEntry {
    struct Complete: Command {
        let launchID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let predicate = NSPredicate(format: "launch.launchID == %@", launchID as CVarArg)

            guard let session = try context.latest(type: SessionEntry.self, predicate: predicate) else {
                return
            }

            if session.endDate == nil {
                session.endDate = Date()
                session.requeue()
                try context.save()
            }
        }
    }
}
