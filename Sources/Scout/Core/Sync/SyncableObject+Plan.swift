//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncableObject {
    static func plan(backends: [Backend], in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SyncableObject>(entityName: "SyncableObject")
        request.predicate = NSPredicate(format: "deliveries.@count == 0")

        for object in try context.fetch(request) where !type(of: object).isLocalOnly {
            for backend in backends {
                let row = context.insert(SyncDelivery.self)
                row.backendID = backend.id
                row.object = object
                row.isPending = true
            }
        }

        try context.save()
    }
}
