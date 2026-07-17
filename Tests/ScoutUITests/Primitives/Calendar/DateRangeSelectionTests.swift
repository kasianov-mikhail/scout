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
@testable import Support

struct DateRangeSelectionTests {
    let day1 = TestDate.reference
    let day3 = TestDate.reference.addingDay(2)
    let day5 = TestDate.reference.addingDay(4)

    @Test("Empty selection has no range") func empty() {
        let selection = DateRangeSelection()

        #expect(selection.range == nil)
        #expect(selection.contains(day1) == false)
        #expect(selection.isEndpoint(day1) == false)
    }

    @Test("First tap sets a single-day start") func firstTap() {
        var selection = DateRangeSelection()
        selection.select(day3)

        #expect(selection.start == day3)
        #expect(selection.end == nil)
        #expect(selection.isEndpoint(day3))
        #expect(selection.range == day3..<day3.addingDay())
    }

    @Test("A later second tap forms the range") func secondTap() {
        var selection = DateRangeSelection()
        selection.select(day1)
        selection.select(day5)

        #expect(selection.start == day1)
        #expect(selection.end == day5)
        #expect(selection.range == day1..<day5.addingDay())
        #expect(selection.contains(day3))
        #expect(selection.isEndpoint(day1))
        #expect(selection.isEndpoint(day5))
        #expect(selection.contains(day5.addingDay()) == false)
    }

    @Test("A tap before the start moves the start") func tapBeforeStart() {
        var selection = DateRangeSelection()
        selection.select(day5)
        selection.select(day1)

        #expect(selection.start == day1)
        #expect(selection.end == nil)
    }

    @Test("A third tap restarts the selection") func thirdTap() {
        var selection = DateRangeSelection()
        selection.select(day1)
        selection.select(day5)
        selection.select(day3)

        #expect(selection.start == day3)
        #expect(selection.end == nil)
    }
}
