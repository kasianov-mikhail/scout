//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SyncDelivery {
    // A single shared increment per cycle, so the per-type delivery passes don't
    // each spend the budget and abandon the backend early. Runs on the main actor
    // because it mutates the main-queue view context.
    @MainActor static func recordAttempt(for backendID: String, in context: NSManagedObjectContext) {
        let request = NSFetchRequest<SyncDelivery>(entityName: "SyncDelivery")
        request.predicate = NSPredicate(
            format: "backendID == %@ AND progressPrimitive != 0 AND attempts < %d",
            backendID,
            SyncDelivery.maxAttempts
        )

        do {
            for delivery in try context.fetch(request) {
                delivery.attempts += 1
            }
            try context.save()
        } catch {
            print("Failed to record delivery attempt: \(error.localizedDescription)")
        }
    }
}
