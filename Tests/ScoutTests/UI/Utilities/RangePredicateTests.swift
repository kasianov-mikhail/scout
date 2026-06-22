//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RangePredicateTests {
    @Test("Date range produces half-open bounds") func dateFilters() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = Date(timeIntervalSinceReferenceDate: 86400)

        let filters = (start..<end).dateFilters

        #expect(
            filters == [
                RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(start)),
                RecordQuery.Filter(field: "date", op: .lessThan, value: .date(end)),
            ]
        )
    }
}
