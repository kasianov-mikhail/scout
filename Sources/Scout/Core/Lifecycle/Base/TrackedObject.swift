//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(TrackedObject)
class TrackedObject: SyncableObject {
    @NSManaged var sessionID: UUID

    override func awakeFromInsert() {
        super.awakeFromInsert()
        sessionID = IDs.session
    }

    func inferredEndDate(in context: NSManagedObjectContext) throws -> Date? {
        let request = NSFetchRequest<TrackedObject>(entityName: "TrackedObject")
        request.predicate = NSPredicate(format: "sessionID == %@", sessionID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.fetchLimit = 1
        return try context.fetch(request).first?.date
    }
}
