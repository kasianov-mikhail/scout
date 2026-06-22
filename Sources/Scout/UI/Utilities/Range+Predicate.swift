//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Range<Date> {
    var dateFilters: [RecordQuery.Filter] {
        [
            RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(lowerBound)),
            RecordQuery.Filter(field: "date", op: .lessThan, value: .date(upperBound)),
        ]
    }
}
