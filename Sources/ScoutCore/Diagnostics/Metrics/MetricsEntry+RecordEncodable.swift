//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension IntMetricsEntry: RecordEncodable {
    static public let recordType = "IntMetric"

    public var record: Record {
        metricRecord(type: Self.recordType, value: value)
    }
}

extension DoubleMetricsEntry: RecordEncodable {
    static public let recordType = "DoubleMetric"

    public var record: Record {
        metricRecord(type: Self.recordType, value: value)
    }
}

extension MetricsEntry {
    fileprivate func metricRecord(type: String, value: some RecordValueConvertible) -> Record {
        var record = Record(recordType: type, recordID: objectID.uriRepresentation().absoluteString)

        record["name"] = name
        record["category"] = telemetry
        record["value"] = value
        record["date"] = date
        record["session_id"] = sessionID?.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString

        record.setValues(metadata)

        return record
    }
}
