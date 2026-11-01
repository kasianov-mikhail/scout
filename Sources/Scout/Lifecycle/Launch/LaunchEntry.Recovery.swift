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
            request.predicate = NSPredicate(format: "endDate == nil")

            for launch in try context.fetch(request) where !openLaunchIDs.contains(launch.launchID) {
                launch.endDate = launch.inferred
                launch.requeue()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
