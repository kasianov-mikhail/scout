//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(DailyMetricEntry)
package final class DailyMetricEntry: SyncableEntry {
    package static let recordType = "DailyMetric"

    @NSManaged var metricID: UUID
    @NSManaged var appVersion: String?
    @NSManaged var name: String
    @NSManaged var category: String?
    @NSManaged var value: Int
    @NSManaged var windowStart: Date?
}

extension DailyMetricEntry: RecordEncodable {
    package var record: Record {
        var record = Record(recordType: Self.recordType, recordID: metricID.uuidString)

        record["name"] = name
        record["category"] = category
        record["value"] = value
        record["app_version"] = appVersion
        record["date"] = date
        record["date_start"] = windowStart
        record["uuid"] = metricID.uuidString

        record.setValues(metadata)

        return record
    }
}
