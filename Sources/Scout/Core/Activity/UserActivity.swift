//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(UserActivity)
final class UserActivity: SyncableObject, Syncable {

    @NSManaged var dayCount: Int32
    @NSManaged var monthCount: Int32
    @NSManaged var period: String?
    @NSManaged var userActivityID: UUID?
    @NSManaged var weekCount: Int32

    @nonobjc class func fetchRequest() -> NSFetchRequest<UserActivity> {
        NSFetchRequest<UserActivity>(entityName: "UserActivity")
    }

    static func group(in context: NSManagedObjectContext) throws -> [UserActivity]? {
        try batch(in: context, matching: [\.month])
    }
}
