//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension SyncGroup {

    /// Creates a new `CKRecord` instance representing a matrix.
    ///
    /// The matrix will include the `name` and `week` properties of the `SyncGroup`.
    ///
    /// - Returns: A new `CKRecord` instance.
    ///
    func newMatrix() -> CKRecord {
        let matrix = CKRecord(recordType: "DateIntMatrix")
        matrix["name"] = name
        matrix["date"] = week
        return matrix
    }

    /// Asynchronously retrieves a CKRecord from the specified database or creates a new one if the database doesn't contain a required matrix.
    ///
    /// - Parameter database: The database conforming to `Database` from which to retrieve the CKRecord.
    /// - Returns: A `CKRecord` retrieved from the specified database or a newly created one.
    /// - Throws: An error if the operation fails.
    ///
    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", week as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and, subpredicates: [namePredicate, datePredicate])

        let query = CKQuery(recordType: "DateIntMatrix", predicate: predicate)
        let desiredKeys = fields.map(\.key)

        let allMatrices = try await database.allRecords(matching: query, desiredKeys: desiredKeys)
        let matrix = allMatrices.randomElement() ?? newMatrix()

        return matrix
    }
}
