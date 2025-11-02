//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivity: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        try trigger(date: Date().startOfDay, in: context)
    }

    static func trigger(date: Date, in context: NSManagedObjectContext) throws {
        for period in ActivityPeriod.allCases {
            let provider = Provider(date: date, period: period)
            let activities = try provider.fetch(in: context)

            let limit = date.adding(period.spreadComponent)

            for activity in activities {
                if let day = activity.day, day < limit, activity[keyPath: period.countField] == 0 {
                    activity[keyPath: period.countField] = 1
                }
            }
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
