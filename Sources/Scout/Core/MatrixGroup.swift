//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A protocol that defines a group of fields for synchronization.
///
/// Types conforming to `MatrixGroup` must provide a name, date, and a dictionary of fields and 
/// their corresponding counts. This protocol is used to group related fields and manage their 
/// synchronization.
///
protocol MatrixGroup: Sendable {

    /// The name of the matrix.
    var name: String { get }

    /// The date of the matrix
    var date: Date { get }

    /// A dictionary mapping field names to their corresponding count values.
    var fields: [String: Int] { get }
}

extension MatrixGroup {

    /// Creates a new `CKRecord` instance representing a matrix.
    ///
    /// The matrix will include the `name` and `date` properties of the `SyncGroup`.
    ///
    /// - Returns: A new `CKRecord` instance.
    ///
    func newMatrix() -> CKRecord {
        let matrix = CKRecord(recordType: "DateIntMatrix")
        matrix["name"] = name
        matrix["date"] = date
        return matrix
    }

    /// Asynchronously retrieves a CKRecord from the specified database or creates a new one if the database doesn't contain a required matrix.
    ///
    /// - Parameters:
    ///   - database: The database conforming to `Database` from which to retrieve the CKRecord.
    ///   - fields: The fields to retrieve from the matrix.
    /// - Returns: A `CKRecord` retrieved from the specified database or a newly created one.
    /// - Throws: An error if the operation fails.
    ///
    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and, subpredicates: [namePredicate, datePredicate])

        let query = CKQuery(recordType: "DateIntMatrix", predicate: predicate)

        let keys = fields.map { key, _ in key }
        let allMatrices = try await database.allRecords(matching: query, desiredKeys: keys)
        let matrix = allMatrices.randomElement() ?? newMatrix()

        return matrix
    }
}
