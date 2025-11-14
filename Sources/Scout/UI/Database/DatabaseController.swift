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

    // MARK: - Fetch

    func record(for recordID: CKRecord.ID) async throws -> CKRecord {
        guard let database else {
            return DatabaseController.sampleData[0]
        }
        return try await database.record(for: recordID)
    }

    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws -> [CKRecord] {
        guard let database else {
            return DatabaseController.sampleData.filter { $0.recordType == query.recordType }
        }
        return try await database.readAll(
            matching: query,
            fields: desiredKeys
        )
    }

    // MARK: - Query with Cursor

    typealias CursorResult = (
        matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)],
        queryCursor: CKQueryOperation.Cursor?
    )

    func records(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]? = nil) async throws -> CursorResult {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            matching: query,
            desiredKeys: desiredKeys
        )
    }

    func records(continuingMatchFrom queryCursor: CKQueryOperation.Cursor, desiredKeys: [CKRecord.FieldKey]? = nil) async throws -> CursorResult {
        guard let database else {
            return (DatabaseController.sampleDataResults, nil)
        }
        return try await database.records(
            continuingMatchFrom: queryCursor,
            desiredKeys: desiredKeys
        )
    }
}
