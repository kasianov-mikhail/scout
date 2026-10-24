//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionEntry {
    struct Recovery: Command {
        let openLaunchIDs: Set<UUID>

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<SessionEntry>(entityName: "SessionEntry")
            request.predicate = .unfinished(launchKey: "launch.launchID", outside: openLaunchIDs)

            for session in try context.fetch(request) {
                session.endDate = session.inferred
                session.requeue()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
