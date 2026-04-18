//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableObject {
    /// Deletes synced objects older than 7 days and objects that
    /// exceeded the sync attempt limit.
    ///
    static func cleanup(in context: NSManagedObjectContext) throws {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate

        let request = NSFetchRequest<SyncableObject>(entityName: "SyncableObject")
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "isSynced == true AND datePrimitive < %@", cutoff),
            NSPredicate(format: "isSynced == false AND syncAttempts > %d", maxSyncAttempts),
        ])

        for object in try context.fetch(request) {
            context.delete(object)
        }

        try context.save()
    }
}
