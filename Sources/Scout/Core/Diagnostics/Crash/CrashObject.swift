//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashObject)
final class CrashObject: TrackedObject {
    static let recordType = "Crash"

    @NSManaged var appVersion: String?
    @NSManaged var name: String?
    @NSManaged var crashID: UUID
    @NSManaged var fingerprint: String?
    @NSManaged var reason: String?
    @NSManaged var stackTrace: Data?
}

extension CrashObject: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: crashID.uuidString)

        record["name"] = name
        record["fingerprint"] = fingerprint ?? CrashFingerprint(name: name ?? "", reason: reason, stackTrace: decodedStackTrace).value
        record["reason"] = reason
        record["stack_trace"] = stackTrace
        record["date"] = date
        record["uuid"] = crashID.uuidString

        record.setValues(metadata)

        return record
    }

    private var decodedStackTrace: [String] {
        guard let stackTrace, let decoded = try? JSONDecoder().decode([String].self, from: stackTrace) else { return [] }
        return decoded
    }
}
