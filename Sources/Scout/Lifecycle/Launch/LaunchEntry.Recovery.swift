//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchEntry {
    struct Recovery: Command {
        let openLaunchIDs: Set<UUID>

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<LaunchEntry>(entityName: "LaunchEntry")
            request.predicate = .unfinished(launchKey: "launchID", outside: openLaunchIDs)

            for launch in try context.fetch(request) {
                launch.endDate = launch.inferred
                launch.requeue()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
