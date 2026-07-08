//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Crash: Incident {
    let name: String
    let fingerprint: String
    let reason: String?
    let stackTrace: [String]
    let date: Date?
    let id: String
    let deviceID: UUID?
    let installID: UUID?
    let launchID: UUID?
    let sessionID: UUID?
}

extension Crash: Comparable {
    static func < (lhs: Crash, rhs: Crash) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension Crash: RecordDecodable {
    static let recordType = CrashObject.recordType

    static let desiredKeys = [
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

    static var samples: [Crash] {
        let counts: KeyValuePairs<String, Int> = ["NSRangeException": 8, "Fatal error": 4, "SIGSEGV": 2]

        var crashes: [Crash] = []
        var index = 0

        for (name, count) in counts {
            for _ in 0..<count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                crashes.append(.sample(name, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return crashes
    }

    init(record: Record) throws {
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
        fingerprint = record["fingerprint"] ?? CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value
    }
}

extension Crash: RecordEncodable {
    var record: Record {
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
