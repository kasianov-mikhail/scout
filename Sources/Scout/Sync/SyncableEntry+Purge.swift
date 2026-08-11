//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableEntry {
    static func purge(to backendIDs: Set<String>, in context: NSManagedObjectContext) throws {
        guard backendIDs.count > 0 else {
            return
        }

        let request = NSFetchRequest<SyncableEntry>(entityName: "SyncableEntry")
        request.predicate = NSPredicate(
            format: "SUBQUERY(deliveries, $d, $d.backendID IN %@ AND $d.isPending == NO).@count == %d",
            backendIDs,
            backendIDs.count
        )

        for object in try context.fetch(request) where object.isPurgeable && object.references.count == 0 {
            context.delete(object)
        }
    }
}
