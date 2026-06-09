//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Session {
    static func fetchChunk(installIDs: [UUID], ascending: Bool, in database: AppDatabase) async throws -> RecordChunk {
        let query = CKQuery(
            recordType: SessionObject.recordType,
            predicate: NSPredicate(format: "install_id IN %@", installIDs.map(\.uuidString))
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "start_date", ascending: ascending)
        ]

        return try await database.read(matching: query, fields: nil, limit: 25)
    }
}
