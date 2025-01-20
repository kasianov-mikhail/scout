//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension UserActivity {

    /// Triggers the creation of `UserActivity` records for the current date.
    ///
    /// This method checks if `UserActivity` records already exist for the current date.
    /// If no records exist, it creates new `UserActivity` records and saves them to the context.
    ///
    /// - Parameter context: The managed object context in which to perform the operation.
    /// - Throws: An error if the operation fails.
    ///
    static func trigger(in context: NSManagedObjectContext) throws {
        try trigger(date: Date().startOfDay, in: context)
    }

    /// Triggers the creation of `UserActivity` records for the specified date.
    ///
    /// This method checks if `UserActivity` records already exist for the specified date.
    /// If no records exist, it creates new `UserActivity` records and saves them to the context.
    ///
    /// - Parameters:
    ///   - date: The date for which to create the `UserActivity` records. Should be the beginning of the day.
    ///   - context: The managed object context in which to perform the operation.
    /// - Throws: An error if the operation fails.
    ///
    static func trigger(date: Date, in context: NSManagedObjectContext) throws {
        for period in ActivityPeriod.allCases {
            let provider = Provider(date: date, period: period)
            let activities = try provider.fetch(in: context)

            let limit = date.adding(period.rangeComponent)

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

// MARK: - Provider

extension UserActivity {

    /// A structure that provides methods for fetching and managing `UserActivity` records.
    ///
    /// The `Provider` structure is used to fetch existing `UserActivity` records for a given date range
    /// and to create new `UserActivity` records if they do not already exist. It helps in managing
    /// the user activity data efficiently by ensuring that the records are up-to-date and complete.
    ///
    fileprivate struct Provider {
        let range: Range<Date>
        let period: ActivityPeriod
    }
}

extension UserActivity.Provider {

    /// Initializes a new instance of `Provider` with the specified date and period.
    ///
    /// - Parameters:
    ///   - date: The date for which the `UserActivity` records are being managed.
    ///   - period: The period for which the user activity is being tracked (e.g., daily, weekly, monthly).
    ///
    init(date: Date, period: ActivityPeriod) {
        self.range = date..<date.adding(period.rangeComponent)
        self.period = period
    }
}

// MARK: - Fetch Activities

extension UserActivity.Provider {

    /// Fetches the `UserActivity` records for the specified date range.
    ///
    /// This method retrieves existing `UserActivity` records for the date range specified by the provider.
    /// If any records are missing within the range, it creates new `UserActivity` records to fill the gaps.
    ///
    /// - Parameter context: The managed object context in which to perform the fetch operation.
    /// - Returns: An array of `UserActivity` records for the specified date range.
    /// - Throws: An error if the fetch operation fails.
    ///
    func fetch(in context: NSManagedObjectContext) throws -> [UserActivity] {
        var activities = try existing(in: context)
        var recent = activities.last?.day?.addingDay() ?? range.lowerBound

        /// Fill in any missing activities
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

        activity.day = date
        activity.week = date.startOfWeek
        activity.month = date.startOfMonth
        activity.period = period.rawValue

        return activity
    }
}

// MARK: - Count Field

extension ActivityPeriod {

    /// A computed property that returns the appropriate count field key path for the activity period.
    ///
    /// This property provides the key path to the count field (`dayCount`, `weekCount`, or `monthCount`)
    /// based on the activity period (`daily`, `weekly`, or `monthly`).
    ///
    fileprivate var countField: ReferenceWritableKeyPath<UserActivity, Int32> {
        switch self {
        case .daily:
            return \.dayCount
        case .weekly:
            return \.weekCount
        case .monthly:
            return \.monthCount
        }
    }
}

// MARK: -

extension UserActivity.Provider: CustomDebugStringConvertible {
    var debugDescription: String {
        "Provider for \(period) activities on \(range)"
    }
}
