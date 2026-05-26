//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct Event: Identifiable, Hashable {
    let name: String
    let level: Level?
    let date: Date?
    let paramCount: Int?
    let uuid: UUID?
    let id: CKRecord.ID
    let installID: UUID?
    let sessionID: UUID?
}

extension Event {
    static let desiredKeys = [
        "name",
        "level",
        "date",
        "param_count",
        "uuid",
        "install_id",
        "session_id",
    ]
}

extension Event: RecordDecodable {
    init(record: CKRecord) throws {
        name = record["name"] ?? ""
        level = record["level"].flatMap { Level(rawValue: $0) }
        date = record["date"]
        paramCount = record["param_count"]
        uuid = record["uuid"].flatMap(UUID.init)
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)
    }
}

extension Event {
    static func sample(_ name: String, at date: Date) -> Event {
        Event(
            name: name,
            level: nil,
            date: date,
            paramCount: nil,
            uuid: nil,
            id: CKRecord.ID(recordName: UUID().uuidString),
            installID: nil,
            sessionID: nil
        )
    }
}
