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
    static func group(in context: NSManagedObjectContext) throws -> [UserActivity]? {
         try batch(in: context, matching: [\.month])
    }

    static func matrix(of batch: [UserActivity]) -> Matrix<PeriodCell<Int>>? {
        guard let month = batch.first?.month else {
            return nil
        }
        return Matrix(
            recordType: "PeriodMatrix",
            date: month,
            name: "ActiveUser",
            cells: parse(of: batch)
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
