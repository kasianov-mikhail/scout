//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

struct ChartExtentMoveTests {
    let week = ScaleStub(horizonDate: Date(year: 2026, month: 6, day: 15), rangeComponent: .weekOfYear)

    @Test("Is left disabled") func testIsLeftDisabled() {
        let model = ChartExtent(period: Period.week, offset: -51)

        #expect(!model.isLeftEnabled)
    }

    @Test("Is left enabled") func testIsLeftEnabled() {
        let model = ChartExtent(period: Period.week)

        #expect(model.isLeftEnabled)
    }

    @Test("Is right disabled") func testIsRightDisabled() {
        let model = ChartExtent(period: Period.week)

        #expect(!model.isRightEnabled)
    }

    @Test("Is right enabled") func testIsRightEnabled() {
        var model = ChartExtent(period: Period.week)

        model.moveLeft()

        #expect(model.isRightEnabled)
    }

    @Test("Move left") func testMoveLeft() {
        var model = ChartExtent(period: week)

        model.moveLeft()

        #expect(model.domain == Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8))
    }

    @Test("Move right") func testMoveRight() {
        var model = ChartExtent(period: week, offset: -2)

        model.moveRight()

        #expect(model.domain == Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8))
    }

    @Test("Move right edge") func testMoveRightEdge() {
        var model = ChartExtent(period: Period.week)

        model.moveLeft()
        model.moveLeft()
        model.moveRightEdge()

        #expect(model.domain == Period.week.initialRange)
    }

    @Test("Left then right returns to the latest month on the 31st")
    func monthEnd() {
        let scale = ScaleStub(horizonDate: Date(year: 2026, month: 3, day: 31), rangeComponent: .month)
        var model = ChartExtent(period: scale)

        model.moveLeft()

        #expect(model.domain == Date(year: 2026, month: 1, day: 31)..<Date(year: 2026, month: 2, day: 28))

        model.moveRight()

        #expect(model.domain == scale.initialRange)
        #expect(!model.isRightEnabled)
    }

    @Test("Left then right returns to the latest year on 29 February")
    func leapDay() {
        let scale = ScaleStub(horizonDate: Date(year: 2028, month: 2, day: 29), rangeComponent: .year)
        var model = ChartExtent(period: scale)

        model.moveLeft()
        model.moveRight()

        #expect(model.domain == scale.initialRange)
        #expect(!model.isRightEnabled)
    }

    @Test("Pages meet without a gap or an overlap")
    func pagesAreAdjacent() {
        let scale = ScaleStub(horizonDate: Date(year: 2026, month: 3, day: 31), rangeComponent: .month)

        for offset in -12..<0 {
            #expect(scale.range(at: offset).upperBound == scale.range(at: offset + 1).lowerBound)
        }
    }

    @Test("Changing the period returns to the latest page")
    func periodChange() {
        var model = ChartExtent(period: Period.week)

        model.moveLeft()
        model.period = .month

        #expect(model.domain == Period.month.initialRange)
    }
}
