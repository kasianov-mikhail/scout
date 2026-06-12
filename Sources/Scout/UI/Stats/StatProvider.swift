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
            let predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    Calendar.utc.defaultRange.datePredicate,
                    NSPredicate(format: "name == %@", eventName),
                ]
            )

            return CKQuery(
                recordType: Int.recordType,
                predicate: predicate
            )
        }
    }
}
