//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension IntMetricsEntry: RecordEncodable {
    static package let recordType = "IntMetric"

    package var record: Record {
        metricRecord(type: Self.recordType, value: value)
    }
}

extension DoubleMetricsEntry: RecordEncodable {
    static package let recordType = "DoubleMetric"

    package var record: Record {
        metricRecord(type: Self.recordType, value: value)
    }
}

extension MetricsEntry {
    fileprivate func metricRecord(type: String, value: some RecordValueConvertible) -> Record {
        var record = sessionRecord(type: type, id: objectID.uriRepresentation().absoluteString)

        record["name"] = name
        record["category"] = telemetry
        record["value"] = value

        return record
    }
}
