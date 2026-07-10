//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchObject: RecoveryMonitor {
    static func completeStale(identity: Identity, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<LaunchObject>(entityName: "LaunchObject")
        request.predicate = NSPredicate(format: "endDate == nil AND launchID != %@", identity.launch as CVarArg)

        for launch in try context.fetch(request) {
            launch.endDate = launch.inferred
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
