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
            let predicate = NSCompoundPredicate(
                type: .and,
                subpredicates: [
                    Calendar.utc.defaultRange.datePredicate,
                    NSPredicate(format: "name == %@", "ActiveUser"),
                ]
            )

            return CKQuery(
                recordType: PeriodCell<Int>.recordType,
                predicate: predicate
            )
        }
    }
}
