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
}

extension DatabaseController {
    func save(_ record: CKRecord) async throws {
        _ = try await database?.save(record)
    }

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

extension DatabaseController {
    /// Helper to execute database operations with fallback to sample data
    private func withDatabase<T>(
        fallback: @autoclosure () -> T,
        operation: (CKDatabase) async throws -> T
    ) async throws -> T {
        guard let database else {
            return fallback()
        }
        return try await operation(database)
    }
    
    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        try await withDatabase(fallback: DatabaseController.sampleData[0]) { database in
            try await database.record(for: recordID)
        }
    }

    func allRecords(
        matching query: CKQuery,
        desiredKeys: [CKRecord.FieldKey]?
    ) async throws -> [CKRecord] {
        try await withDatabase(fallback: DatabaseController.sampleData.filter { $0.recordType == query.recordType }) { database in
            try await database.allRecords(
                matching: query,
                desiredKeys: desiredKeys
            )
        }
    }
}

extension DatabaseController {
    typealias Results = [(CKRecord.ID, Result<CKRecord, any Error>)]
    typealias CursorResult = (matchResults: Results, queryCursor: CKQueryOperation.Cursor?)

    func records(
        matching query: CKQuery,
        desiredKeys: [CKRecord.FieldKey]? = nil
    ) async throws -> CursorResult {
        try await withDatabase(fallback: (DatabaseController.sampleDataResults, nil)) { database in
            try await database.records(
                matching: query,
                desiredKeys: desiredKeys
            )
        }
    }

    func records(
        continuingMatchFrom queryCursor: CKQueryOperation.Cursor,
        desiredKeys: [CKRecord.FieldKey]? = nil
    ) async throws -> CursorResult {
        try await withDatabase(fallback: (DatabaseController.sampleDataResults, nil)) { database in
            try await database.records(
                continuingMatchFrom: queryCursor,
                desiredKeys: desiredKeys
            )
        }
    }
}
