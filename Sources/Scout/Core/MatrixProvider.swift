//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A provider of a matrix.
///
/// The matrix is a two-dimensional array of integers.
///  The provider defines the matrix's name, week, and keys to retrieve from the remote database.
///
protocol MatrixProvider {

    /// The name of the matrix
    var name: String { get }

    /// The week of the matrix
    var week: Date { get }

    /// The keys to retrieve from the remote database
    var keys: [String] { get }
}

extension MatrixProvider {

    /// Creates a new `CKRecord` instance representing a matrix.
    ///
    /// The matrix will include the `name` and `week` properties of the `MatrixProvider`.
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
    /// - Parameters:
    ///   - database: The database conforming to `Database` from which to retrieve the CKRecord.
    ///   - fields: The fields to retrieve from the matrix.
    /// - Returns: A `CKRecord` retrieved from the specified database or a newly created one.
    /// - Throws: An error if the operation fails.
    ///
    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", week as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and, subpredicates: [namePredicate, datePredicate])

        let query = CKQuery(recordType: "DateIntMatrix", predicate: predicate)

        let allMatrices = try await database.allRecords(matching: query, desiredKeys: keys)
        let matrix = allMatrices.randomElement() ?? newMatrix()

        return matrix
    }
}
