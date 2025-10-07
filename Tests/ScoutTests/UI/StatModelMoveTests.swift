//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ChartModelMoveTests {
    let date = Date()

    @Test("Is left disabled") func testIsLeftDisabled() {
        let range = Period.year.range
        let model = ChartModel(period: Period.week, range: range)

        #expect(!model.isLeftEnabled)
    }

    @Test("Is left enabled") func testIsLeftEnabled() {
        let range = Period.week.range
        let model = ChartModel(period: Period.week, range: range)

        #expect(model.isLeftEnabled)
    }

    @Test("Is right disabled") func testIsRightDisabled() {
        let range = Period.week.range
        let model = ChartModel(period: Period.week, range: range)

        #expect(!model.isRightEnabled)
    }

    @Test("Is right enabled") func testIsRightEnabled() {
        let range = Period.week.range
        var model = ChartModel(period: Period.week, range: range)

        model.moveLeft()

        #expect(model.isRightEnabled)
    }

    @Test("Move left") func testMoveLeft() {
        let range = date..<date.addingTimeInterval(3600 * 24 * 7)
        var model = ChartModel(period: Period.week, range: range)

        model.moveLeft()

        let expectedRange = date.addingTimeInterval(-3600 * 24 * 7)..<date
        #expect(model.range == expectedRange)
    }

    @Test("Move right") func testMoveRight() {
        let interval: Double = 3600 * 24 * 7
        let range = date..<date.addingTimeInterval(interval)
        var model = ChartModel(period: Period.week, range: range)

        model.moveRight()

        let expectedRange =
            date.addingTimeInterval(interval)..<date.addingTimeInterval(2 * interval)
        #expect(model.range == expectedRange)
    }

    @Test("Move right edge") func testMoveRightEdge() {
        let range = Period.week.range
        var model = ChartModel(period: Period.week, range: range)

        model.moveLeft()
        model.moveLeft()
        model.moveRightEdge()

        #expect(model.range == range)
    }
}
