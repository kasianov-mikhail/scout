//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension ScreenEntry {
    struct Recovery: Command {
        let openLaunchIDs: Set<UUID>

        func execute(in context: NSManagedObjectContext) throws {
            let request = NSFetchRequest<ScreenEntry>(entityName: "ScreenEntry")
            request.predicate = .unfinished(launchKey: "session.launch.launchID", outside: openLaunchIDs)

            for screen in try context.fetch(request) {
                screen.endDate = screen.session?.endDate ?? screen.date
                screen.requeue()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}
