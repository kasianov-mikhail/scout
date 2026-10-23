//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IssueEntry)
final class IssueEntry: SyncableEntry {
    static let recordType = IncidentIssue.recordType

    @NSManaged var fingerprint: String
    @NSManaged var kind: String
    @NSManaged var status: String
    @NSManaged var resolvedVersion: String?
}

extension IssueEntry: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: "\(kind)-\(fingerprint)")
        record["fingerprint"] = fingerprint
        record["category"] = kind
        record["status"] = status
        record["resolved_version"] = resolvedVersion
        record["date"] = date
        return record
    }
}
