//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject: RecoveryMonitor {
    static func completeStale(in context: NSManagedObjectContext) throws {
        let currentLaunch = context.persistentStoreCoordinator.flatMap {
            IDs.resolve($0.hubObjectIDs.launch, as: LaunchObject.self, in: context)
        }
        let notCurrentLaunch =
            currentLaunch.map {
                NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "launch != %@", $0),
                    NSPredicate(format: "launch == nil"),
                ])
            } ?? NSPredicate(value: true)

        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "endDate == nil"),
            notCurrentLaunch,
        ])

        for session in try context.fetch(request) {
            session.endDate = try session.inferredEndDate(in: context)
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
