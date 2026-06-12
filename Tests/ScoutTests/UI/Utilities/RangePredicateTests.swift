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
    @Test("Date range predicate matches dates in the half-open range") func datePredicate() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = Date(timeIntervalSinceReferenceDate: 86400)
        let predicate = (start..<end).datePredicate

        #expect(predicate.evaluate(with: ["date": start]))
        #expect(predicate.evaluate(with: ["date": start.addingTimeInterval(3600)]))
        #expect(!predicate.evaluate(with: ["date": end]))
        #expect(!predicate.evaluate(with: ["date": start.addingTimeInterval(-1)]))
    }
}
