//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IncidentEntry)
package class IncidentEntry: SyncableEntry {
    @NSManaged var appVersion: String?
    @NSManaged var name: String?
    @NSManaged var fingerprint: String?
    @NSManaged var reason: String?
    @NSManaged var source: String?
    @NSManaged var stackTrace: Data?
    @NSManaged var windowStart: Date?
}

extension HasSession where Self: IncidentEntry {
    func incident(type: String, id: UUID) -> Record {
        var record = sessionRecord(type: type, id: id.uuidString)

        record["name"] = name
        record["fingerprint"] =
            fingerprint ?? CrashFingerprint(name: name ?? "", reason: reason, stackTrace: decodedStackTrace).value
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["uuid"] = id.uuidString
        record["app_version"] = appVersion
        IncidentSource(entry: self).encode(into: &record)

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
