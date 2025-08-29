//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(UserActivity)
final class UserActivity: NSManagedObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<UserActivity>? {
        let seedReq = UserActivity.fetchRequest()
        seedReq.predicate = NSPredicate(format: "isSynced == false")
        seedReq.fetchLimit = 1

        guard let seed = try context.fetch(seedReq).first else {
            return nil
        }
        guard let month = seed.month else {
            throw SyncableError.missingProperty(#keyPath(UserActivity.month))
        }

        let batchReq = UserActivity.fetchRequest()
        batchReq.predicate = NSPredicate(
            format: "isSynced == false AND month == %@",
            month as NSDate
        )

        let batch = try context.fetch(batchReq)

        return SyncGroup<UserActivity>(
            recordType: "PeriodMatrix",
            name: "ActiveUser",
            date: month,
            representables: nil,
            batch: batch
        )
    }

    static func parse(of batch: [UserActivity]) -> [PeriodCell<Int>] {
        batch.compactMap(\.matrix).mergeDuplicates()
    }

    private var matrix: PeriodCell<Int>? {
        guard let month, let day else {
            return nil
        }
        guard let raw = period, let period = ActivityPeriod(rawValue: raw) else {
            return nil
        }
        return PeriodCell(
            period: period,
            day: Calendar.UTC.dateComponents([.day], from: month, to: day).day ?? 0,
            value: Int(self[keyPath: period.countField])
        )
    }
}
