//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Crash {
    package let name: String
    package let fingerprint: String
    package let reason: String?
    package let stackTrace: [String]
    package let date: Date?
    package let id: String
    package let deviceID: UUID?
    package let installID: UUID?
    package let launchID: UUID?
    package let sessionID: UUID?

    package init(
        name: String, fingerprint: String, reason: String?, stackTrace: [String], date: Date?, id: String,
        deviceID: UUID?, installID: UUID?, launchID: UUID?, sessionID: UUID?
    ) {
        self.name = name
        self.fingerprint = fingerprint
        self.reason = reason
        self.stackTrace = stackTrace
        self.date = date
        self.id = id
        self.deviceID = deviceID
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
    }
}

extension Crash: Comparable {
    static package func < (lhs: Crash, rhs: Crash) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Crash: RecordDecodable {
    package static let recordType = CrashEntry.recordType

    package static let desiredKeys = [
        "name",
        "fingerprint",
        "reason",
        "stack_trace",
        "date",
        "uuid",
        "device_id",
        "install_id",
        "launch_id",
        "session_id",
    ]

    package init(record: Record) throws {
        name = record["name"] ?? ""
        reason = record["reason"]
        date = record["date"]
        id = record.recordID
        deviceID = record["device_id"].flatMap(UUID.init)
        installID = record["install_id"].flatMap(UUID.init)
        launchID = record["launch_id"].flatMap(UUID.init)
        sessionID = record["session_id"].flatMap(UUID.init)

        if let data: Data = record["stack_trace"], let decoded = try? JSONDecoder().decode([String].self, from: data) {
            stackTrace = decoded
        } else {
            stackTrace = []
        }
        fingerprint =
            record["fingerprint"] ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension Crash: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["name"] = name
        record["fingerprint"] = fingerprint
        record["reason"] = reason
        record["stack_trace"] = try? JSONEncoder().encode(stackTrace)
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        record["install_id"] = installID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["session_id"] = sessionID?.uuidString
        return record
    }
}
