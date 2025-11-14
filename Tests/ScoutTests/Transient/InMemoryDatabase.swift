//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

final class InMemoryDatabase: Database, @unchecked Sendable {
    var records: [CKRecord] = []
    var errors: [Error] = []

    func store(record: CKRecord) async throws {
        if let error = errors.popLast() {
            throw error
        } else {
            records.append(record)
        }
    }

    func store(records: [CKRecord]) async throws {
        if let error = errors.popLast() {
            throw error
        } else {
            self.records += records
        }
    }

    func fetchAll(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> [CKRecord] {
        let predicate = query.predicate
        predicate.allowEvaluation()
        return records.filter(predicate.evaluate)
    }
}

extension InMemoryDatabase {
    var events: [CKRecord] {
        records.filter { $0.recordType == "Event" }
    }
}
