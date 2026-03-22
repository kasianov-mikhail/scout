//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(UserActivityObject)
final class UserActivityObject: SyncableObject, Syncable {
    @NSManaged var dayCount: Int32
    @NSManaged var monthCount: Int32
    @NSManaged var period: String?
    @NSManaged var userActivityID: UUID?
    @NSManaged var weekCount: Int32

    static func group(in context: NSManagedObjectContext) throws -> [UserActivityObject]? {
        try batch(in: context, matching: [\.month])
    }
}
