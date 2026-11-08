//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Session: Identifiable {
    package let startDate: Date?
    package let endDate: Date?
    package let id: String
    package let sessionID: UUID?
    package let launchID: UUID?
    package let installID: UUID?
    package let deviceID: UUID?
    package let osVersion: String?
    package let appVersion: String?

    package init(startDate: Date?, endDate: Date?, id: String, sessionID: UUID?, launchID: UUID?, installID: UUID?, deviceID: UUID? = nil, osVersion: String? = nil, appVersion: String? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.id = id
        self.sessionID = sessionID
        self.launchID = launchID
        self.installID = installID
        self.deviceID = deviceID
        self.osVersion = osVersion
        self.appVersion = appVersion
    }
}

extension Session: RecordDecodable {
    package static let recordType = "Session"

    package static let desiredKeys = [
        "start_date",
        "end_date",
        "session_id",
        "launch_id",
        "install_id",
        "device_id",
        "os_version",
        "app_version",
    ]

    package init(record: Record) throws {
        startDate = record["start_date"]
        endDate = record["end_date"]
        id = record.recordID
        sessionID = record["session_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
        osVersion = record["os_version"]
        appVersion = record["app_version"]
    }
}

extension Session: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["start_date"] = startDate
        record["end_date"] = endDate
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString
        record["os_version"] = osVersion
        record["app_version"] = appVersion
        return record
    }
}
