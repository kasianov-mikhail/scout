//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivity {
    struct Provider {
        let range: Range<Date>
        let period: ActivityPeriod

        init(date: Date, period: ActivityPeriod) {
            self.range = date..<date.adding(period.spreadComponent)
            self.period = period
        }
    }
}

extension UserActivity.Provider {
    func fetch(in context: NSManagedObjectContext) throws -> [UserActivity] {
        var activities = try existing(in: context)
        var recent = activities.last?.day?.addingDay() ?? range.lowerBound

        // Fill in any missing activities
        while recent < range.upperBound {
            let activity = newActivity(for: recent, in: context)
            activities.append(activity)
            recent.addDay()
        }

        return activities
    }

    func existing(in context: NSManagedObjectContext) throws -> [UserActivity] {
        let request = UserActivity.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserActivity.day, ascending: true)
        ]

        request.predicate = NSPredicate(
            format: "day >= %@ AND day < %@ AND period == %@",
            range.lowerBound as NSDate,
            range.upperBound as NSDate,
            period.rawValue
        )

        return try context.fetch(request)
    }

    func newActivity(for date: Date, in context: NSManagedObjectContext) -> UserActivity {
        let entity = NSEntityDescription.entity(forEntityName: "UserActivity", in: context)!
        let activity = UserActivity(entity: entity, insertInto: context)

        activity.date = date
        activity.period = period.rawValue

        return activity
    }
}

extension UserActivity.Provider: CustomDebugStringConvertible {
    var debugDescription: String {
        "Provider for \(period) activities on \(range)"
    }
}
