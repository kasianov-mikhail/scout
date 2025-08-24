//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

typealias SyncValue = MatrixValue & CKRecordValueProtocol & AdditiveArithmetic & Sendable

struct SyncGroup<T: SyncValue>: @unchecked Sendable {
    let recordType: String
    let name: String
    let date: Date
    let objects: [Syncable]
    let fields: [String: T]
}

extension SyncGroup {
    func newMatrix() -> Matrix<Cell<T>> {
        Matrix(
            date: date,
            name: name,
            recordID: nil,
            cells: fields.map(Cell.init)
        )
    }

    func matrix(in database: Database) async throws -> Matrix<Cell<T>> {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let allMatrices = try await database.allRecords(matching: query, desiredKeys: nil)

        if let randomRecord = allMatrices.randomElement() {
            return try Matrix(record: randomRecord)
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
          objects: \(objects.count) items,
          fields: \(fields)
        )
        """
    }
}
