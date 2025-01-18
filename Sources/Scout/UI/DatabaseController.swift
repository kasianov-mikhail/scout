//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

/// The `DatabaseController` class is responsible for managing the database operations.
/// It provides methods to perform CRUD (Create, Read, Update, Delete) operations on the database.
/// This class ensures that all database interactions are handled efficiently and securely.
///
final class DatabaseController: ObservableObject, Sendable {

    /// The underlying database instance used by the controller.
    let database: CKDatabase?

    /// Initializes a new instance of the `DatabaseController` with the specified database.
    ///
    /// - Parameter database: The `Database` instance to be used by the controller.
    ///
    init(database: CKDatabase? = nil) {
        self.database = database
    }
}

// MARK: - Save, Modify and Delete Records

extension DatabaseController {

    /// Saves the provided CloudKit record to the database.
    ///
    /// - Parameter record: The `CKRecord` to be saved.
    /// - Throws: An error if the save operation fails.
    ///
    func save(_ record: CKRecord) async throws {
        _ = try await database?.save(record)
    }

    /// Modifies records in the database by saving and deleting specified records.
    ///
    /// - Parameters:
    ///   - recordsToSave: An array of `CKRecord` objects to be saved to the database.
    ///   - recordIDsToDelete: An array of `CKRecord.ID` objects representing the records to be deleted from the database.
    /// - Throws: An error if the operation fails.
    ///
    func modifyRecords(
        saving recordsToSave: [CKRecord],
        deleting recordIDsToDelete: [CKRecord.ID]
    ) async throws {
        _ = try await database?.modifyRecords(
            saving: recordsToSave,
            deleting: recordIDsToDelete
        )
    }
}

// MARK: - Fetching Records

extension DatabaseController {

    /// Fetches the record with the specified record ID from the database. Returns sample data if the database is not available.
    ///
    /// - Parameter recordID: The ID of the record to fetch.
    /// - Returns: The `CKRecord` object with the specified ID.
    /// - Throws: An error if the operation fails.
    ///
    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let database else {
            return DatabaseController.sampleData[0]
        }
        return try await database.record(for: recordID)
    }

    /// Fetches all records from the database that match the specified query. Returns sample data if the database is not available.
    ///
    /// - Parameters:
    ///   - query: The `CKQuery` object that defines the criteria for selecting records.
    ///   - desiredKeys: An optional array of `CKRecord.FieldKey` specifying the fields to be fetched. If `nil`, all fields are fetched.
    /// - Returns: An array of `CKRecord` objects that match the query.
    /// - Throws: An error if the operation fails.
    ///
    func allRecords(
        matching query: CKQuery,
        desiredKeys: [CKRecord.FieldKey]?
    ) async throws -> [CKRecord] {
        guard let database else {
            return DatabaseController.sampleData.filter { $0.recordType == query.recordType }
        }
        return try await database.allRecords(
            matching: query,
            desiredKeys: desiredKeys
        )
    }
}

// MARK: - Fetching Records with Query Cursors

extension DatabaseController {

    /// A typealias representing an array of tuples, where each tuple contains a `CKRecord.ID` and a `Result`
    /// that holds either a `CKRecord` or any type of `Error`.
    ///
    /// This typealias is used to simplify the representation of results obtained from CloudKit operations,
    /// where each operation can either succeed with a `CKRecord` or fail with an `Error`.
    ///
    /// Example usage:
    /// ```swift
    /// let results: Results = [
    ///     (recordID1, .success(record1)),
    ///     (recordID2, .failure(someError))
    /// ]
    /// ```
    ///
    typealias Results = [(CKRecord.ID, Result<CKRecord, any Error>)]

    /// A typealias representing the result of a database query operation, including the match results and an optional query cursor.
    ///
    /// - `matchResults`: The results of the query operation.
    /// - `queryCursor`: An optional cursor that can be used to fetch the next batch of results in a paginated query.
    ///
    typealias CursorResult = (matchResults: Results, queryCursor: CKQueryOperation.Cursor?)
}

extension DatabaseController {

    /// Fetches records from the database that match the specified query. Returns sample data if the database is not available.
    /// This method returns a tuple containing the matching records and a query cursor for fetching additional records.
    /// The query cursor can be used to fetch additional records that match the query.
    ///
    /// - Parameters:
    ///  - query: The `CKQuery` object that defines the criteria for selecting records.
    ///  - desiredKeys: An optional array of `CKRecord.FieldKey` specifying the fields to be fetched. If `nil`, all fields are fetched.
    ///  - Returns: A tuple containing the matching records and a query cursor for fetching additional records.
    ///  - Throws: An error if the operation fails.
    ///
    func records(
        matching query: CKQuery,
        desiredKeys: [CKRecord.FieldKey]? = nil
    ) async throws -> CursorResult {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            matching: query,
            desiredKeys: desiredKeys
        )
    }

    /// Fetches records from the database that match the specified query cursor. Returns sample data if the database is not available.
    /// This method is used to fetch additional records that match a query when the initial query returns a query cursor.
    ///
    /// - Parameters:
    ///  - queryCursor: The `CKQueryOperation.Cursor` object that represents the continuation of a previous query.
    ///  - desiredKeys: An optional array of `CKRecord.FieldKey` specifying the fields to be fetched. If `nil`, all fields are fetched.
    ///  - Returns: A tuple containing the matching records and a query cursor for fetching additional records.
    ///  - Throws: An error if the operation fails.
    ///
    func records(
        continuingMatchFrom queryCursor: CKQueryOperation.Cursor,
        desiredKeys: [CKRecord.FieldKey]? = nil
    ) async throws -> CursorResult {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            continuingMatchFrom: queryCursor,
            desiredKeys: desiredKeys
        )
    }
}
