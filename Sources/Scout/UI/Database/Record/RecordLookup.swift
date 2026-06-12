//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol RecordLookup {
    func lookup(id: CKRecord.ID, fields: [CKRecord.FieldKey]?) async throws -> CKRecord
}

extension CKDatabase: RecordLookup {
    func lookup(id: CKRecord.ID, fields: [CKRecord.FieldKey]?) async throws -> CKRecord {
        try await runner { database in
            guard let result = try await database.records(for: [id], desiredKeys: fields)[id] else {
                throw CKError(.unknownItem)
            }
            return try result.get()
        }
    }
}
