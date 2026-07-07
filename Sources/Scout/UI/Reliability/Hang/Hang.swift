//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Hang: ReliabilityRecord {
    let name: String
    let fingerprint: String
    let reason: String?
    let stackTrace: [String]
    let duration: TimeInterval
    let date: Date?
    let id: String
    let deviceID: UUID?
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

extension Hang {
    var severity: HangSeverity {
        duration >= 8 ? .critical : .warning
    }

    var durationText: String {
        duration < 60 ? String(format: "%.1fs", duration) : "\(Int(duration) / 60)m \(Int(duration) % 60)s"
    }
}

extension Hang: Comparable {
    static func < (lhs: Hang, rhs: Hang) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Hang: RecordDecodable {
    static let recordType = HangObject.recordType

    static let desiredKeys = [
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

    init(record: Record) throws {
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
        fingerprint = record["fingerprint"] ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension Hang: RecordEncodable {
    var record: Record {
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
