//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(UserActivity)
final class UserActivity: SyncableObject, Syncable, MatrixBatch {
    static func group(in context: NSManagedObjectContext) throws -> [UserActivity]? {
        try batch(in: context, matching: [\.month])
    }

    static func matrix(of batch: [UserActivity]) throws(MatrixPropertyError) -> Matrix<PeriodCell<Int>> {
        guard let month = batch.first?.month else {
            throw .init("month")
        }
        return Matrix(
            recordType: "PeriodMatrix",
            date: month,
            name: "ActiveUser",
            cells: parse(of: batch)
        )
    }
}
