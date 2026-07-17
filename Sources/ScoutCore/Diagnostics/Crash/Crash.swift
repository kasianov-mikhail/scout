//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Crash {
    public let name: String
    public let fingerprint: String
    public let reason: String?
    public let stackTrace: [String]
    public let date: Date?
    public let id: String
    public let deviceID: UUID?
    public let installID: UUID?
    public let launchID: UUID?
    public let sessionID: UUID?

    public init(
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
    static public func < (lhs: Crash, rhs: Crash) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Crash: RecordDecodable {
    public static let recordType = CrashEntry.recordType

    public static let desiredKeys = [
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

    public init(record: Record) throws {
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
    public var record: Record {
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
