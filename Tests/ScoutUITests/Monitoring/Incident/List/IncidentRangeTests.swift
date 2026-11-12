//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("Incident range")
struct IncidentRangeTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("Each range ends after today and covers its whole day count")
    func current() {
        for range in IncidentRange.allCases {
            let window = range.range(now: now)
            #expect(window.lowerBound == now.startOfDay.addingDay(1 - range.dayCount))
            #expect(window.upperBound == now.startOfDay.addingDay())
        }
    }

    @Test("The previous range ends where the current one starts")
    func previous() {
        for range in IncidentRange.allCases {
            let current = range.range(now: now)
            let previous = range.previousRange(now: now)

            #expect(previous.upperBound == current.lowerBound)
            #expect(previous.lowerBound == current.lowerBound.addingDay(-range.dayCount))
        }
    }

    @Test("The strip uses the design titles")
    func titles() {
        #expect(IncidentRange.allCases.map(\.title) == ["7 days", "30 days", "Year"])
    }
}
