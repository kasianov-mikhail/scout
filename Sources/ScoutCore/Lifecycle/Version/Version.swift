//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Version {
    public let appVersion: String?
    public let buildNumber: String?
    public let launchID: UUID?
    public let date: Date?
    public let id: String

    public init(appVersion: String?, buildNumber: String?, launchID: UUID?, date: Date?, id: String) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.launchID = launchID
        self.date = date
        self.id = id
    }
}

extension Version: RecordDecodable {
    public static let recordType = VersionEntry.recordType

    public static let desiredKeys = [
        "app_version",
        "build_number",
        "launch_id",
        "date",
    ]

    public init(record: Record) throws {
        appVersion = record["app_version"]
        buildNumber = record["build_number"]
        launchID = record["launch_id"].flatMap(UUID.init)
        date = record["date"]
        id = record.recordID
    }
}

extension Version: RecordEncodable {
    public var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["launch_id"] = launchID?.uuidString
        record["date"] = date
        return record
    }
}
