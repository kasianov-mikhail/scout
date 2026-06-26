//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: RecordLocator {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        try await runner { database in
            let recordID = CKRecord.ID(recordName: recordName)
            guard let result = try await database.records(for: [recordID], desiredKeys: fields)[recordID] else {
                throw RecordNotFoundError()
            }
            return try Record(ckRecord: result.get())
        }
    }
}
