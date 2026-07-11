//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension ActivityEntry {
    struct Provider {
        let range: Range<Date>
        let period: ActivityPeriod

        init(date: Date, period: ActivityPeriod) {
            self.range = date..<date.adding(period.spreadComponent)
            self.period = period
        }
    }
}

extension ActivityEntry.Provider {
    func fetch(sessionID: UUID, in context: NSManagedObjectContext) throws -> [ActivityEntry] {
        var activities = try existing(in: context)
        var recent = activities.last?.day?.addingDay() ?? range.lowerBound

        while recent < range.upperBound {
            let activity = try newActivity(sessionID: sessionID, for: recent, in: context)
            activities.append(activity)
            recent.addDay()
        }

        return activities
    }

    func existing(in context: NSManagedObjectContext) throws -> [ActivityEntry] {
        let request = NSFetchRequest<ActivityEntry>(entityName: "ActivityEntry")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ActivityEntry.day, ascending: true)
        ]

        request.predicate = NSPredicate(
            format: "day >= %@ AND day < %@ AND period == %@",
            range.lowerBound as NSDate,
            range.upperBound as NSDate,
            period.rawValue
        )

        return try context.fetch(request)
    }

    func newActivity(sessionID: UUID, for date: Date, in context: NSManagedObjectContext) throws -> ActivityEntry {
        let activity = context.insert(ActivityEntry.self)

        activity.userActivityID = UUID()
        activity.date = date
        activity.period = period.rawValue
        activity.session = try context.existing(SessionEntry.self, key: "sessionID", id: sessionID)

        return activity
    }
}
