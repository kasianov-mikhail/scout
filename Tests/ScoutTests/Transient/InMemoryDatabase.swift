//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

/// An in-memory implementation of the `Database` protocol.
/// This class provides a database that stores data in memory,
/// which means that all data will be lost when the application terminates.
///
/// - Note: This class is intended for use in testing or scenarios where
///         persistence is not required.
///
final class InMemoryDatabase: Database, @unchecked Sendable {
    var records: [CKRecord] = []
    var errors: [Error] = []
    var result = DatabaseResult([:], [:])

    func save(_ record: CKRecord) async throws -> CKRecord {
        if let error = errors.popLast() {
            throw error
        } else {
            records.append(record)
            return record
        }
    }

    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID])
        async throws -> DatabaseResult
    {
        if let error = errors.popLast() {
            throw error
        } else {
            records += recordsToSave
            records.removeAll { recordIDsToDelete.contains($0.recordID) }
            return result
        }
    }

    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws
        -> [CKRecord]
    {
        let predicate = query.predicate
        predicate.allowEvaluation()
        return records.filter(predicate.evaluate)
    }
}

extension InMemoryDatabase {
    var events: [CKRecord] {
        records.filter { $0.recordType == "Event" }
    }

    var matrices: [CKRecord] {
        records.filter { $0.recordType == "DateIntMatrix" }
    }
}
