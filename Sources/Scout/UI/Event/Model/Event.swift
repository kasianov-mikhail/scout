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

    static let desiredKeys = Key.allCases.map(\.rawValue)

    static var samples: [Event] {
        let names = ["app_launch", "screen_view", "button_tap", "purchase", "login", "logout"]
        return (0..<40).map { index in
            Event.sample(
                names[index % names.count],
                at: Date(timeIntervalSinceNow: -Double(index) * 1800),
                sessionID: UUID()
            )
        }
    }

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

extension Event: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record[Key.name.rawValue] = name
        record[Key.level.rawValue] = level?.rawValue
        record[Key.date.rawValue] = date
        record[Key.paramCount.rawValue] = paramCount
        record[Key.uuid.rawValue] = uuid?.uuidString
        record[Key.installID.rawValue] = installID?.uuidString
        record[Key.sessionID.rawValue] = sessionID?.uuidString
        record[Key.deviceID.rawValue] = deviceID?.uuidString
        return record
    }
}

extension Event {
    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Event {
        Event(
            name: name,
            level: nil,
            date: date,
            paramCount: nil,
            uuid: nil,
            id: UUID().uuidString,
            installID: nil,
            sessionID: sessionID,
            deviceID: nil
        )
    }
}
