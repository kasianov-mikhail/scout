//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Crash: Identifiable {
    let name: String
    let reason: String?
    let stackTrace: [String]
    let date: Date?
    let id: CKRecord.ID
    let userID: UUID?
    let launchID: UUID?
}

extension Crash {
    static let desiredKeys = [
        "name",
        "reason",
        "stack_trace",
        "date",
        "uuid",
        "user_id",
        "launch_id",
    ]
}

extension Crash {
    init(results: (CKRecord.ID, Result<CKRecord, Error>)) throws {
        try self.init(record: results.1.get())
    }

    init(record: CKRecord) throws {
        name = record["name"] ?? ""
        reason = record["reason"]
        date = record["date"]
        id = record.recordID
        userID = record["user_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)

        if let data = record["stack_trace"] as? Data, let decoded = try? JSONDecoder().decode([String].self, from: data) {
            stackTrace = decoded
        } else {
            stackTrace = []
        }
    }
}
