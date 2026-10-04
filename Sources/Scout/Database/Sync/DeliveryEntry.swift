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

    static func retainedIDs(to backendIDs: Set<String>, in context: NSManagedObjectContext) throws -> Set<
        NSManagedObjectID
    > {
        let request = NSFetchRequest<NSDictionary>(entityName: "DeliveryEntry")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["object"]
        request.predicate = NSPredicate(
            format: "backendID IN %@ AND isPending == YES AND attempts < %d",
            backendIDs,
            DeliveryEntry.maxAttempts
        )

        return Set(try context.fetch(request).compactMap { $0["object"] as? NSManagedObjectID })
    }
}
