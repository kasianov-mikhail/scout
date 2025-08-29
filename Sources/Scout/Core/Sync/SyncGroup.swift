//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

struct SyncGroup<T: Syncable>: @unchecked Sendable {
    let recordType: String
    let name: String
    let date: Date
    let representables: [CKRepresentable]?
    let batch: [T]
}

extension SyncGroup {
    func newMatrix() -> Matrix<T.Value> {
        Matrix(
            date: date,
            name: name,
            recordID: CKRecord.ID(),
            cells: T.parse(of: batch)
        )
    }

    func matrix(in database: Database) async throws -> Matrix<T.Value> {
        let name = NSPredicate(format: "name == %@", name)
        let date = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [name, date])
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let matrices = try await database.allRecords(matching: query, desiredKeys: nil)

        if let record = matrices.randomElement() {
            return try Matrix(record: record)
        } else {
            return newMatrix()
        }
    }
}

extension SyncGroup: CustomStringConvertible {
    var description: String {
        """
        SyncGroup(
          recordType: "\(recordType)",
          name: "\(name)",
          date: \(date),
          batch: \(batch.count) items,
        )
        """
    }
}
