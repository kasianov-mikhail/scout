//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A typealias representing the result of a database operation.
/// This typealias is used to simplify the representation of the result
/// returned from various database operations within the application.
///
typealias DatabaseResult = (
    saveResults: [CKRecord.ID: Result<CKRecord, any Error>],
    deleteResults: [CKRecord.ID: Result<Void, any Error>]
)

/// A protocol that defines the required methods and properties for a database.
/// Conforming types are expected to implement the necessary functionality to
/// interact with a database, including operations such as fetching, saving,
/// and deleting data.
///
protocol Database: Sendable {

    /// Saves the provided CloudKit record.
    ///
    /// - Parameter record: The `CKRecord` to be saved.
    /// - Returns: The saved `CKRecord`.
    /// - Throws: An error if the save operation fails.
    ///
    @discardableResult
    func save(_ record: CKRecord) async throws -> CKRecord

    /// Modifies records in the database by saving the specified records and deleting the specified record IDs.
    ///
    /// - Parameters:
    ///   - recordsToSave: An array of `CKRecord` objects that need to be saved to the database.
    ///   - recordIDsToDelete: An array of `CKRecord.ID` objects that need to be deleted from the database.
    ///
    @discardableResult
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID])
        async throws -> DatabaseResult

    /// Fetches records from the database that match the specified query.
    ///
    /// - Parameters:
    ///   - query: The `CKQuery` object that defines the criteria for selecting records.
    ///   - desiredKeys: An optional array of `CKRecord.FieldKey` specifying the fields to be fetched. If `nil`, all fields are fetched.
    ///
    /// - Throws: An error if the operation fails.
    ///
    /// - Returns: An array of `CKRecord` objects that match the query.
    ///
    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws
        -> [CKRecord]
}

// MARK: - CloudKit Database Extension

extension CKDatabase: Database {

    /// Modifies records in the database by saving and deleting specified records.
    ///
    /// - Parameters:
    ///   - saving: An array of `CKRecord` objects to be saved to the database.
    ///   - deleting: An array of `CKRecord.ID` objects representing the records to be deleted from the database.
    /// - Returns: A `DatabaseResult` object containing the results of the save and delete operations.
    /// - Throws: An error if the operation fails.
    ///
    /// - Throws: An error if the query or subsequent fetch operations fail.
    ///
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID])
        async throws -> DatabaseResult
    {
        try await runner { database in
            try await database.modifyRecords(
                saving: recordsToSave,
                deleting: recordIDsToDelete,
                savePolicy: .ifServerRecordUnchanged,
                atomically: true
            )
        }
    }

    /// Fetches records from the database that match the given query.
    ///
    /// This function performs an asynchronous query to fetch records from the database.
    /// If the query results exceed the maximum limit, it continues fetching using a cursor
    /// until all matching records are retrieved.
    ///
    /// - Parameters:
    ///   - query: The `CKQuery` object that defines the conditions for the records to fetch.
    ///   - desiredKeys: An optional array of field keys that specify which fields to fetch for each record.
    ///
    /// - Returns: An array of `CKRecord` objects that match the query.
    ///
    /// - Throws: An error if the query or subsequent fetch operations fail.
    ///
    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws
        -> [CKRecord]
    {
        let results = try await runner { database in
            try await database.records(
                matching: query,
                desiredKeys: desiredKeys,
                resultsLimit: CKQueryOperation.maximumResults
            )
        }

        var cursorOrNil = results.queryCursor
        var result = try results.matchResults.map { try $0.1.get() }

        while let cursor = cursorOrNil {
            let continuing = try await runner { database in
                try await database.records(
                    continuingMatchFrom: cursor,
                    resultsLimit: CKQueryOperation.maximumResults
                )
            }

            cursorOrNil = continuing.queryCursor
            result += try continuing.matchResults.map { try $0.1.get() }
        }

        return result
    }
}
