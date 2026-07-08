//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(TrackedObject)
class TrackedObject: SyncableObject {
    @NSManaged var session: SessionObject?

    var sessionID: String { session?.id.uuidString ?? "" }

    override func awakeFromInsert() {
        super.awakeFromInsert()

        if let context = managedObjectContext, let coordinator = context.persistentStoreCoordinator {
            session = IDs.resolve(coordinator.hubObjectIDs.session, as: SessionObject.self, in: context)
        }
    }

    // Most recent datePrimitive among TrackedObjects whose session relationship
    // points at self — called with self as the SessionObject itself.
    func inferredEndDate(in context: NSManagedObjectContext) throws -> Date? {
        let request = NSFetchRequest<NSDictionary>(entityName: "TrackedObject")
        request.predicate = NSPredicate(format: "session == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: false)]
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [DateObject.datePrimitiveKey]
        request.fetchLimit = 1
        return try context.fetch(request).first?[DateObject.datePrimitiveKey] as? Date ?? date
    }
}
