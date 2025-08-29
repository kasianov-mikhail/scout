//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension UserActivity {
    @discardableResult static func stub(
        month: Date,
        day: Date,
        period: ActivityPeriod,
        count: Int,
        isSynced: Bool,
        in context: NSManagedObjectContext
    ) -> UserActivity {
        let entity = NSEntityDescription.entity(forEntityName: "UserActivity", in: context)!
        let activity = UserActivity(entity: entity, insertInto: context)

        activity.userActivityID = UUID()
        activity.month = month
        activity.day = day
        activity.period = period.rawValue
        activity.isSynced = isSynced

        // Set all count fields to 0, then set the relevant one
        activity.dayCount = 0
        activity.weekCount = 0
        activity.monthCount = 0

        activity[keyPath: period.countField] = Int32(count)

        return activity
    }
}
