//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(HangObject)
final class HangObject: TrackedObject {
    static let recordType = "Hang"

    @NSManaged var appVersion: String?
    @NSManaged var name: String?
    @NSManaged var hangID: UUID
    @NSManaged var fingerprint: String?
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?
    @NSManaged var duration: Double
}

extension HangObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: hangID.uuidString)

        record["name"] = name
        record["fingerprint"] = fingerprint ?? CrashFingerprint(name: name ?? "", reason: reason, stackTrace: decodedStackTrace).value
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["duration"] = duration
        record["date"] = date
        record["uuid"] = hangID.uuidString
        record["app_version"] = appVersion
        record["session_id"] = sessionID.uuidString

        record.setValues(metadata)

        return record
    }

    private var decodedStackTrace: [String] {
        guard let stackTrace, let decoded = try? JSONDecoder().decode([String].self, from: stackTrace) else {
            return []
        }
        return decoded
    }
}
