//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: RecordWriter {
    func write(record: Record) async throws {
        do {
            try await runner { database in
                try await database.save(record.ckRecord)
            }
        } catch let error as CKError where error.code == .serverRecordChanged {
            guard let server = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else {
                throw error
            }
            throw RecordConflictError(serverRecord: Record(ckRecord: server))
        }
    }

    func write(records: [Record]) async throws {
        for chunk in records.chunked(into: Self.maxBatchSize) {
            try await runner { database in
                try await database.modifyRecords(
                    saving: chunk.map(\.ckRecord),
                    deleting: [],
                    savePolicy: .allKeys,
                    atomically: true
                )
            }
        }
    }
}
