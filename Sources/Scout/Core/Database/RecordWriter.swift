//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol RecordWriter {
    func write(record: CKRecord) async throws
    func write(records: [CKRecord]) async throws
}

extension CKDatabase: RecordWriter {
    func write(record: CKRecord) async throws {
        try await runner { database in
            try await database.save(record)
        }
    }

    func write(records: [CKRecord]) async throws {
        try await runner { database in
            try await database.modifyRecords(
                saving: records,
                deleting: [],
                savePolicy: .ifServerRecordUnchanged,
                atomically: true
            )
        }
    }
}
