//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

final class DatabaseController: ObservableObject, Sendable {
    let database: CKDatabase?

    init(database: CKDatabase? = nil) {
        self.database = database
    }

    // MARK: - Save

    func save(_ record: CKRecord) async throws {
        _ = try await database?.save(record)
    }

    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID])
        async throws
    {
        _ = try await database?.modifyRecords(
            saving: recordsToSave,
            deleting: recordIDsToDelete
        )
    }

    // MARK: - Fetch

    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let database else {
            return DatabaseController.sampleData[0]
        }
        return try await database.record(for: recordID)
    }

    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws
        -> [CKRecord]
    {
        guard let database else {
            return DatabaseController.sampleData.filter { $0.recordType == query.recordType }
        }
        return try await database.allRecords(
            matching: query,
            desiredKeys: desiredKeys
        )
    }

    // MARK: - Query with Cursor

    typealias Cursor = CKQueryOperation.Cursor
    typealias Results = [(CKRecord.ID, Result<CKRecord, any Error>)]

    typealias CursorResult = (matchResults: Results, queryCursor: Cursor?)

    func records(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]? = nil) async throws
        -> CursorResult
    {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            matching: query,
            desiredKeys: desiredKeys
        )
    }

    func records(continuingMatchFrom queryCursor: Cursor, desiredKeys: [CKRecord.FieldKey]? = nil)
        async throws -> CursorResult
    {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            continuingMatchFrom: queryCursor,
            desiredKeys: desiredKeys
        )
    }
}
