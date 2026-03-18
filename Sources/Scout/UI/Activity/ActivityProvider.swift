//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class ActivityProvider: QueryProvider<ActivityMatrix> {
    init() {
        super.init {
            let dateRange = Calendar.utc.defaultRange

            let predicate = NSPredicate(
                format: "date >= %@ AND date < %@ AND name == %@",
                dateRange.lowerBound as NSDate,
                dateRange.upperBound as NSDate,
                "ActiveUser"
            )

            return CKQuery(
                recordType: "PeriodMatrix",
                predicate: predicate
            )
        }
    }
}
