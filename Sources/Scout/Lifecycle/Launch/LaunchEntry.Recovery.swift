//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchEntry {
    struct Recovery: Command {
        let launchID: UUID

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<LaunchEntry>(entityName: "LaunchEntry")
            request.predicate = NSPredicate(format: "endDate == nil AND launchID != %@", launchID as CVarArg)

            for launch in try context.fetch(request) {
                launch.endDate = launch.inferred
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
