//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Event: Identifiable {
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

    static let desiredKeys = Key.allCases.map(\.rawValue)
}

extension Event {
    private enum Key: String, CaseIterable {
        case name
        case level
        case date
        case paramCount = "param_count"
        case uuid
        case installID = "install_id"
        case sessionID = "session_id"
        case deviceID = "device_id"
    }

    init(record: Record) throws {
        name = record[Key.name.rawValue] ?? ""
        level = record[Key.level.rawValue].flatMap { Level(rawValue: $0) }
        date = record[Key.date.rawValue]
        paramCount = record[Key.paramCount.rawValue]
        uuid = record[Key.uuid.rawValue].flatMap(UUID.init)
        id = record.recordID
        installID = record[Key.installID.rawValue].flatMap(UUID.init)
        sessionID = record[Key.sessionID.rawValue].flatMap(UUID.init)
        deviceID = record[Key.deviceID.rawValue].flatMap(UUID.init)
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
