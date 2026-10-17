//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(PerformanceEntry)
package final class PerformanceEntry: SyncableEntry {
    package static let recordType = "Performance"

    @NSManaged var performanceID: UUID
    @NSManaged var appVersion: String?
    @NSManaged var metric: String
    @NSManaged var bucket: String?
    @NSManaged var value: Int
    @NSManaged var windowStart: Date?
}

extension PerformanceEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: performanceID.uuidString)

        record["name"] = metric
        record["category"] = bucket
        record["value"] = value
        record["app_version"] = appVersion
        record["date"] = date
        record["date_start"] = windowStart
        record["uuid"] = performanceID.uuidString

        record.setValues(metadata)

        return record
    }
}
