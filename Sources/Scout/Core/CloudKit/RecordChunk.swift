//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct RecordChunk {
    let records: [CKRecord]
    let cursor: CKQueryOperation.Cursor?
}

// MARK: - CloudKit Mapping

extension RecordChunk {
    init(results: ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)) throws {
        records = try results.0.records()
        cursor = results.1
    }
}

extension [(CKRecord.ID, Result<CKRecord, Error>)] {
    fileprivate func records() throws -> [CKRecord] {
        try map { try $0.1.get() }
    }
}

// MARK: - Operators

extension RecordChunk {
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        RecordChunk(
            records: lhs.records + rhs.records,
            cursor: rhs.cursor
        )
    }
}
