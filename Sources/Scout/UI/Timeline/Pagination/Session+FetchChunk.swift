//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Session {
    static func fetchChunk(installIDs: [UUID], anchor: Date?, ascending: Bool, in database: AppDatabase) async throws -> RecordChunk {
        var predicates = [
            NSPredicate(format: "install_id IN %@", installIDs.map(\.uuidString))
        ]

        // The anchor session itself starts at or before the anchor event, so
        // it belongs to the descending (older) lane; the ascending lane picks
        // up strictly later sessions.
        if let anchor {
            predicates.append(
                NSPredicate(format: ascending ? "start_date > %@" : "start_date <= %@", anchor as NSDate)
            )
        }

        let query = CKQuery(
            recordType: SessionObject.recordType,
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        )
        query.sortDescriptors = [
            NSSortDescriptor(key: "start_date", ascending: ascending)
        ]

        return try await database.read(matching: query, fields: nil, limit: 25)
    }
}
