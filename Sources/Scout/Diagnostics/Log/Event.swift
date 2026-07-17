//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Event: Identifiable {
    package let name: String
    package let level: EventLevel?
    package let date: Date?
    package let paramCount: Int?
    package let uuid: UUID?
    package let id: String
    package let installID: UUID?
    package let sessionID: UUID?
    package let deviceID: UUID?

    package init(
        name: String, level: EventLevel?, date: Date?, paramCount: Int?, uuid: UUID?, id: String, installID: UUID?,
        sessionID: UUID?, deviceID: UUID?
    ) {
        self.name = name
        self.level = level
        self.date = date
        self.paramCount = paramCount
        self.uuid = uuid
        self.id = id
        self.installID = installID
        self.sessionID = sessionID
        self.deviceID = deviceID
    }
}

extension Event: RecordDecodable {
    package static let recordType = EventEntry.recordType

    package static let desiredKeys = Key.allCases.map(\.rawValue)

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

    package init(record: Record) throws {
        name = record[Key.name.rawValue] ?? ""
        level = record[Key.level.rawValue].flatMap { EventLevel(rawValue: $0) }
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
    package var record: Record {
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
