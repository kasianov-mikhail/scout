//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: Database {
    func store(record: CKRecord) async throws {
        try await runner { database in
            try await database.save(record)
        }
    }

    func store(records: [CKRecord]) async throws {
        try await runner { database in
            try await database.modifyRecords(
                saving: records,
                deleting: [],
                savePolicy: .ifServerRecordUnchanged,
                atomically: true
            )
        }
    }

    func fetchAll(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> [CKRecord] {
        let results = try await runner { database in
            try await database.records(
                matching: query,
                desiredKeys: fields,
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
