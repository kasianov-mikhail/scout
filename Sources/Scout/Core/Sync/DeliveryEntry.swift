//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DeliveryEntry)
final class DeliveryEntry: NSManagedObject {
    static let maxAttempts = 10

    @NSManaged var backendID: String
    @NSManaged var isPending: Bool
    @NSManaged var attempts: Int16
    @NSManaged var object: SyncableEntry

    @MainActor static func recordAttempt(for backendID: String, in context: NSManagedObjectContext) {
        let request = NSFetchRequest<DeliveryEntry>(entityName: "DeliveryEntry")
        request.predicate = NSPredicate(
            format: "backendID == %@ AND isPending == YES AND attempts < %d",
            backendID,
            DeliveryEntry.maxAttempts
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

    static func retainedIDs(to backendIDs: Set<String>, in context: NSManagedObjectContext) throws -> Set<NSManagedObjectID> {
        let request = NSFetchRequest<DeliveryEntry>(entityName: "DeliveryEntry")
        request.predicate = NSPredicate(
            format: "backendID IN %@ AND isPending == YES AND attempts < %d",
            backendIDs,
            DeliveryEntry.maxAttempts
        )

        return Set(try context.fetch(request).map(\.object.objectID))
    }
}
