//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class StatProvider: QueryProvider<GridMatrix<Int>> {
    let eventName: String
    let periods: [Period]

    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods

        super.init {
            let dateRange = Calendar.utc.defaultRange

            let predicate = NSPredicate(
                format: "date >= %@ AND name == %@",
                dateRange.lowerBound as NSDate,
                eventName
            )

            return CKQuery(
                recordType: "DateIntMatrix",
                predicate: predicate
            )
        }
    }
}
