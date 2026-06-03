//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Session {
    static func fetchChunk(installID: UUID, in database: AppDatabase) async throws -> RecordChunk {
        let query = CKQuery(
            recordType: SessionObject.recordType,
            predicate: NSPredicate(format: "install_id == %@", installID.uuidString)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "start_date", ascending: false)
        ]

        return try await database.read(matching: query, fields: nil, limit: 10)
    }
}
