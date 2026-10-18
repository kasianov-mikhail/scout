//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

@objc(BacktraceEntry)
package final class BacktraceEntry: SyncableEntry {
    package static let recordType = "Backtrace"

    @NSManaged var incidentID: UUID
    @NSManaged var appVersion: String?
    @NSManaged var payload: Data
}

extension BacktraceEntry: RecordEncodable {
    package var record: Record {
        let id = UUID(incidentBacktrace: incidentID)
        var record = Record(recordType: Self.recordType, recordID: id.uuidString)

        record["uuid"] = id.uuidString
        record["incident_id"] = incidentID.uuidString
        record["backtrace"] = payload
        record["date"] = date
        record["app_version"] = appVersion

        return record
    }
}

extension UUID {
    init(incidentBacktrace: UUID) {
        self.init(digesting: [BacktraceEntry.recordType, incidentBacktrace.uuidString])
    }
}
