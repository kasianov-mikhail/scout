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
        try context.objects(TrackedObject.self, where: "sessionID == %@", sessionID, dateAscending: false, limit: 1).first?.date
    }
}
