//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Event: Identifiable, Hashable {
    let name: String
    let level: Level?
    let date: Date?
    let paramCount: Int?
    let uuid: UUID?
    let id: String
    let installID: UUID?
    let sessionID: UUID?
    let deviceID: UUID?
}

extension Event: RecordDecodable {
    static let recordType = EventObject.recordType
    static let sampleRecords: [Record] = []

    static let desiredKeys = [
        "name",
        "level",
        "date",
        "param_count",
        "uuid",
        "install_id",
        "session_id",
        "device_id",
    ]
}

extension Event {
    init(record: Record) throws {
        name = record["name"] ?? ""
        level = record["level"].flatMap { Level(rawValue: $0) }
        date = record["date"]
        paramCount = record["param_count"]
        uuid = record["uuid"].flatMap(UUID.init)
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
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
            id: UUID().uuidString,
            installID: nil,
            sessionID: nil,
            deviceID: nil
        )
    }
}
