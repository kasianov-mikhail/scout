//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class MetricsProvider<T: ChartNumeric>: QueryProvider<GridMatrix<T>> {
    init(telemetry: Telemetry.Export) {
        super.init {
            let dateRange = Calendar.utc.defaultRange

            let predicate = NSPredicate(
                format: "date >= %@ AND date < %@ AND category == %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate,
                telemetry.rawValue
            )

            return CKQuery(
                recordType: T.recordName,
                predicate: predicate
            )
        }
    }
}
