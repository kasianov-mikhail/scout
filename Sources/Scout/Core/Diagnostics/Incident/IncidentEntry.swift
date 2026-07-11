//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IncidentEntry)
class IncidentEntry: SyncableEntry {
    @NSManaged var appVersion: String?
    @NSManaged var name: String?
    @NSManaged var fingerprint: String?
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?
}

extension HasSession where Self: IncidentEntry {
    func incident(type: String, id: UUID) -> Record {
        var record = Record(recordType: type, recordID: id.uuidString)

        record["name"] = name
        record["fingerprint"] = fingerprint ?? CrashFingerprint(name: name ?? "", reason: reason, stackTrace: decodedStackTrace).value
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["date"] = date
        record["uuid"] = id.uuidString
        record["app_version"] = appVersion
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }

    private var decodedStackTrace: [String] {
        if let stackTrace, let decoded = try? JSONDecoder().decode([String].self, from: stackTrace) {
            decoded
        } else {
            []
        }
    }
}
