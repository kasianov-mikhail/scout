//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Session: Identifiable {
    public let startDate: Date?
    public let endDate: Date?
    public let id: String
    public let sessionID: UUID?
    public let launchID: UUID?
    public let installID: UUID?

    public init(startDate: Date?, endDate: Date?, id: String, sessionID: UUID?, launchID: UUID?, installID: UUID?) {
        self.startDate = startDate
        self.endDate = endDate
        self.id = id
        self.sessionID = sessionID
        self.launchID = launchID
        self.installID = installID
    }
}

extension Session: RecordDecodable {
    public static let recordType = SessionEntry.recordType

    public static let desiredKeys = [
        "start_date",
        "end_date",
        "session_id",
        "launch_id",
        "install_id",
    ]

    public init(record: Record) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        sessionID = record["session_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
    }
}

extension Session: RecordEncodable {
    public var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["start_date"] = startDate
        record["end_date"] = endDate
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        return record
    }
}
