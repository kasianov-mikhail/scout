//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionEntry {
    struct Recovery: Command {
        let launchID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<SessionEntry>(entityName: "SessionEntry")
            request.predicate = NSPredicate(format: "endDate == nil AND launch.launchID != %@", launchID as CVarArg)

            for session in try context.fetch(request) {
                session.endDate = session.inferred
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
