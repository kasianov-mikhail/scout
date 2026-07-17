//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension SyncableEntry {
    @discardableResult
    func seedDelivery(
        pending: Bool = true, attempts: Int16 = 0, for backendID: String, in context: NSManagedObjectContext
    ) -> DeliveryEntry {
        let entity = NSEntityDescription.entity(forEntityName: "DeliveryEntry", in: context)!
        let row = delivery(for: backendID) ?? DeliveryEntry(entity: entity, insertInto: context)
        row.backendID = backendID
        row.object = self
        row.isPending = pending
        row.attempts = attempts
        return row
    }

    func setSynced(_ synced: Bool, in context: NSManagedObjectContext) {
        for row in deliveries {
            context.delete(row)
        }
    }
}

extension DeliveryEntry {
    var isDelivered: Bool { !isPending }
    var isAbandoned: Bool { attempts >= Self.maxAttempts }
}
