//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Hang {
    package let name: String
    package let fingerprint: String
    package let reason: String?
    package let stackTrace: [String]
    package let duration: TimeInterval
    package let date: Date?
    package let id: String
    package let deviceID: UUID?
    package let installID: UUID?
    package let launchID: UUID?
    package let sessionID: UUID?

    package init(
        name: String, fingerprint: String, reason: String?, stackTrace: [String], duration: TimeInterval, date: Date?,
        id: String, deviceID: UUID?, installID: UUID?, launchID: UUID?, sessionID: UUID?
    ) {
        self.name = name
        self.fingerprint = fingerprint
        self.reason = reason
        self.stackTrace = stackTrace
        self.duration = duration
        self.date = date
        self.id = id
        self.deviceID = deviceID
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
    }
}

extension Hang: Comparable {
    static package func < (lhs: Hang, rhs: Hang) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Hang: RecordDecodable {
    package static let recordType = HangEntry.recordType

    package static let desiredKeys = [
        "name",
        "fingerprint",
        "reason",
        "stack_trace",
        "duration",
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
        duration = record["duration"] ?? 0
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

extension Hang: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["name"] = name
        record["fingerprint"] = fingerprint
        record["reason"] = reason
        record["stack_trace"] = try? JSONEncoder().encode(stackTrace)
        record["duration"] = duration
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        record["install_id"] = installID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["session_id"] = sessionID?.uuidString
        return record
    }
}
