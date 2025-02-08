//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivity: Syncable {

    /// Fetches the most recent `UserActivity` from the given `NSManagedObjectContext` and uses its
    /// `month` property to find all activities that match this criteria. It then groups
    /// the activities by their `month` property.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup? {
        let activityRequest = UserActivity.fetchRequest()
        activityRequest.predicate = NSPredicate(format: "isSynced == false")
        activityRequest.fetchLimit = 1

        guard let activity = try context.fetch(activityRequest).first else {
            return nil
        }
        guard let month = activity.month else {
            throw SyncableError.missingProperty(#keyPath(UserActivity.month))
        }

        let groupRequest = UserActivity.fetchRequest()

        groupRequest.predicate = NSPredicate(
            format: "isSynced == false && month == %@",
            month as NSDate
        )

        let activities = try context.fetch(groupRequest)

        return SyncGroup(
            name: "ActiveUser",
            date: month,
            objectIDs: activities.map(\.objectID),
            fields: Dictionary(uniqueKeysWithValues: activities.compactMap(\.matrix))
        )
    }

    private var matrix: (String, Int)? {
        guard let month, let day else {
            return nil
        }
        guard let rawPeriod = period, let period = ActivityPeriod(rawValue: rawPeriod) else {
            return nil
        }

        let days = Calendar.UTC.dateComponents([.day], from: month, to: day).day ?? 0
        let components = ["cell", period.shortTitle, String(format: "%02d", days)]
        let joined = components.joined(separator: "_")
        let count = self[keyPath: period.countField]

        return (joined, Int(count))
    }
}
