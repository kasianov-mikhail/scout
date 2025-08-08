//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A dated, named collection of integer counters for CloudKit sync.
protocol MatrixGroup: Sendable {

    /// CloudKit record type.
    var recordType: String { get }

    /// Logical name of the matrix.
    var name: String { get }

    /// Date represented by the matrix.
    var date: Date { get }

    /// Field names and their counts.
    var fields: [String: Int] { get }
}

extension MatrixGroup {

    /// Creates a new unsaved `CKRecord` with `name`, `date`, and version.
    ///
    /// - Returns: A new `CKRecord` for this matrix.
    ///
    func newMatrix() -> CKRecord {
        let matrix = CKRecord(recordType: recordType)
        matrix["name"] = name
        matrix["date"] = date
        matrix["version"] = 1
        return matrix
    }

    /// Fetches a matching record from `database` or creates a new one.
    ///
    /// Matches on `name` and `date`.
    /// Returns a random match if multiple exist.
    ///
    /// - Parameter database: The database to search in.
    /// - Returns: An existing or new `CKRecord` for this matrix.
    /// - Throws: If the database query fails.
    ///
    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [namePredicate, datePredicate]
        )
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let keys = fields.map { key, _ in key }
        let allMatrices = try await database.allRecords(matching: query, desiredKeys: keys)
        return allMatrices.randomElement() ?? newMatrix()
    }
}
