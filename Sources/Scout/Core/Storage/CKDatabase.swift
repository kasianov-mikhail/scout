//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: Database {
    func modifyRecords(
        saving recordsToSave: [CKRecord],
        deleting recordIDsToDelete: [CKRecord.ID]
    ) async throws -> DatabaseResult {
        try await runner { database in
            try await database.modifyRecords(
                saving: recordsToSave,
                deleting: recordIDsToDelete,
                savePolicy: .ifServerRecordUnchanged,
                atomically: true
            )
        }
    }

    func allRecords(
        matching query: CKQuery,
        desiredKeys: [CKRecord.FieldKey]?
    ) async throws -> [CKRecord] {
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
