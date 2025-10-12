//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Event: Identifiable {
    let name: String
    let level: Level?
    let date: Date?
    let paramCount: Int?
    let uuid: UUID?
    let id: CKRecord.ID
    let userID: UUID?
    let sessionID: UUID?
}

extension Event {
    static let desiredKeys = [
        "name",
        "level",
        "date",
        "param_count",
        "uuid",
        "user_id",
        "session_id",
    ]
}

extension Event {
    init(results: (CKRecord.ID, Result<CKRecord, Error>)) throws {
        try self.init(record: results.1.get())
    }

    init(record: CKRecord) throws {
        name = record["name"] ?? ""
        level = record["level"].flatMap(Level.init)
        date = record["date"]
        paramCount = record["param_count"]
        uuid = record["uuid"].flatMap(UUID.init)
        id = record.recordID
        userID = record["user_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)
    }
}
