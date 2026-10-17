//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct ResourceException {
    package let name: String
    package let fingerprint: String
    package let reason: String?
    package let stackTrace: [String]
    package let resourceKind: ResourceKind?
    package let date: Date?
    package let id: String
    package let deviceID: UUID?
    package let installID: UUID?
    package let launchID: UUID?
    package let sessionID: UUID?

    package init(name: String, fingerprint: String, reason: String?, stackTrace: [String], resourceKind: ResourceKind?, date: Date?, id: String, deviceID: UUID?, installID: UUID?, launchID: UUID?, sessionID: UUID?) {
        self.name = name
        self.fingerprint = fingerprint
        self.reason = reason
        self.stackTrace = stackTrace
        self.resourceKind = resourceKind
        self.date = date
        self.id = id
        self.deviceID = deviceID
        self.installID = installID
        self.launchID = launchID
        self.sessionID = sessionID
    }
}

extension ResourceException: Comparable {
    static package func < (lhs: ResourceException, rhs: ResourceException) -> Bool {
        (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
    }
}

extension ResourceException: RecordDecodable {
    package static let recordType = ResourceEntry.recordType

    package static let desiredKeys = [
        "name",
        "fingerprint",
        "reason",
        "stack_trace",
        "category",
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
        resourceKind = record["category"].flatMap(ResourceKind.init(rawValue:))
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
        fingerprint = record["fingerprint"] ?? CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value
    }
}

extension ResourceException: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: id)
        record["name"] = name
        record["fingerprint"] = fingerprint
        record["reason"] = reason
        do {
            record["stack_trace"] = try JSONEncoder().encode(stackTrace)
        } catch {
            print("Failed to encode the stack trace: \(error)")
        }
        record["category"] = resourceKind?.rawValue
        record["date"] = date
        record["device_id"] = deviceID?.uuidString
        record["install_id"] = installID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["session_id"] = sessionID?.uuidString
        return record
    }
}
