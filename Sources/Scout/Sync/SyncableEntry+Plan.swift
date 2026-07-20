//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableEntry {
    static func plan(backends: [Backend], in context: NSManagedObjectContext) throws {
        for backend in backends {
            let request = NSFetchRequest<SyncableEntry>(entityName: "SyncableEntry")
            request.predicate = NSPredicate(
                format: "SUBQUERY(deliveries, $d, $d.backendID == %@).@count == 0",
                backend.id
            )

            for object in try context.fetch(request) {
                let row = context.insert(DeliveryEntry.self)
                row.backendID = backend.id
                row.object = object
                row.isPending = true
            }
        }

        try context.save()
    }
}
