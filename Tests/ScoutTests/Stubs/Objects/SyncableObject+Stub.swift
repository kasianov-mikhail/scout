//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension SyncableObject {
    @discardableResult
    func seedDelivery(_ progress: SyncDelivery.Progress, attempts: Int16 = 0, for backendID: String, in context: NSManagedObjectContext) -> SyncDelivery {
        let row = delivery(for: backendID) ?? SyncDelivery(context: context)
        row.backendID = backendID
        row.object = self
        row.progress = progress
        row.attempts = attempts
        return row
    }

    func setSynced(_ synced: Bool, in context: NSManagedObjectContext) {
        for row in deliveries {
            context.delete(row)
        }
    }
}

extension SyncDelivery {
    var isDelivered: Bool { progress.isEmpty }
    var isAbandoned: Bool { attempts >= Self.maxAttempts }
}
