//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableObject {
    /// Deletes synced objects older than ``RetentionPolicy/syncedRecordLifetime``
    /// and objects that exceeded ``RetentionPolicy/maxSyncAttempts``.
    ///
    static func cleanup(in context: NSManagedObjectContext) throws {
        let retention = activeSetupOptions.retention
        let cutoff = Date().addingTimeInterval(-retention.syncedRecordLifetime)

        let request = NSFetchRequest<SyncableObject>(entityName: "SyncableObject")
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "isSynced == true AND datePrimitive < %@", cutoff as NSDate),
            NSPredicate(format: "isSynced == false AND syncAttempts > %d", retention.maxSyncAttempts),
        ])

        for object in try context.fetch(request) {
            context.delete(object)
        }

        try context.save()
    }
}
