//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// Maximum number of records per CloudKit modify request.
private let maxBatchSize = 400

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
        for chunk in records.chunked(into: maxBatchSize) {
            try await runner { database in
                try await database.modifyRecords(
                    saving: chunk,
                    deleting: [],
                    savePolicy: .ifServerRecordUnchanged,
                    atomically: true
                )
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
