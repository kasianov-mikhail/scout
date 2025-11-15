//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

final class InMemoryDatabase: Database {
    var records: [CKRecord] = []
    var errors: [Error] = []

    func write(record: CKRecord) async throws {
        if let error = errors.popLast() {
            throw error
        } else {
            records.append(record)
        }
    }

    func write(records: [CKRecord]) async throws {
        if let error = errors.popLast() {
            throw error
        } else {
            self.records += records
        }
    }

    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        if let error = errors.popLast() {
            throw error
        }
        let predicate = query.predicate
        predicate.allowEvaluation()
        return RecordChunk(
            records: records.filter(predicate.evaluate),
            cursor: nil
        )
    }

    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        if let error = errors.popLast() {
            throw error
        }
        return RecordChunk(
            records: [],
            cursor: nil
        )
    }
}

extension InMemoryDatabase {
    var events: [CKRecord] {
        records.filter { $0.recordType == "Event" }
    }
}
