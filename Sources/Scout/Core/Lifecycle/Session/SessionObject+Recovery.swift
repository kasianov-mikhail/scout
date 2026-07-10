//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: RecoveryMonitor {
    static func completeStale(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = NSPredicate(format: "endDate == nil AND launch.launchID != %@", IDs.launch as CVarArg)

        for session in try context.fetch(request) {
            session.endDate = session.inferred
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
