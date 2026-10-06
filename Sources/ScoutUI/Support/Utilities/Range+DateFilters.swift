//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Range<Date> {
    var dateFilters: [RecordQuery.Filter] {
        dateFilters(on: "date")
    }

    func dateFilters(on field: String) -> [RecordQuery.Filter] {
        [
            RecordQuery.Filter(field: field, op: .greaterThanOrEquals, value: .date(lowerBound)),
            RecordQuery.Filter(field: field, op: .lessThan, value: .date(upperBound)),
        ]
    }
}
