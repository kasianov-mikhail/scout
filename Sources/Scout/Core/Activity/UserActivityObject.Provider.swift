//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivityObject {
    struct Provider {
        let range: Range<Date>
        let period: ActivityPeriod

        init(date: Date, period: ActivityPeriod) {
            self.range = date..<date.adding(period.spreadComponent)
            self.period = period
        }
    }
}

extension UserActivityObject.Provider {
    func fetch(in context: NSManagedObjectContext) throws -> [UserActivityObject] {
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

    func existing(in context: NSManagedObjectContext) throws -> [UserActivityObject] {
        let request = NSFetchRequest<UserActivityObject>(entityName: "UserActivityObject")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \UserActivityObject.day, ascending: true)
        ]

        request.predicate = NSPredicate(
            format: "day >= %@ AND day < %@ AND period == %@",
            range.lowerBound as NSDate,
            range.upperBound as NSDate,
            period.rawValue
        )

        return try context.fetch(request)
    }

    func newActivity(for date: Date, in context: NSManagedObjectContext) -> UserActivityObject {
        let entity = NSEntityDescription.entity(forEntityName: "UserActivityObject", in: context)!
        let activity = UserActivityObject(entity: entity, insertInto: context)

        activity.userActivityID = UUID()
        activity.date = date
        activity.period = period.rawValue

        return activity
    }
}

extension UserActivityObject.Provider: CustomDebugStringConvertible {
    var debugDescription: String {
        "Provider for \(period) activities on \(range)"
    }
}
