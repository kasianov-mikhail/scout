//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct HeatmapGridTests {
    @Test("Points bucket into weekday and hour cells")
    func bucketing() throws {
        let monday = try makeDate(year: 2026, month: 7, day: 13, hour: 9)
        let sunday = try makeDate(year: 2026, month: 7, day: 19, hour: 23)
        let grid = HeatmapGrid(
            points: [
                ChartPoint(date: monday, count: 3),
                ChartPoint(date: sunday, count: 5),
            ],
            range: try weekRange(),
            calendar: .utc
        )

        #expect(grid.counts[0][9] == 3)
        #expect(grid.counts[6][23] == 5)
        #expect(grid.counts.joined().reduce(0, +) == 8)
    }

    @Test("Points in the same cell accumulate across weeks")
    func accumulation() throws {
        let first = try makeDate(year: 2026, month: 7, day: 13, hour: 9)
        let second = try makeDate(year: 2026, month: 7, day: 6, hour: 9)
        let range = try makeDate(year: 2026, month: 7, day: 6)..<makeDate(year: 2026, month: 7, day: 20)
        let grid = HeatmapGrid(
            points: [
                ChartPoint(date: first, count: 3),
                ChartPoint(date: second, count: 4),
            ],
            range: range,
            calendar: .utc
        )

        #expect(grid.counts[0][9] == 7)
    }

    @Test("Points outside the range are ignored")
    func rangeFiltering() throws {
        let inside = try makeDate(year: 2026, month: 7, day: 13, hour: 9)
        let before = try makeDate(year: 2026, month: 7, day: 6, hour: 9)
        let after = try makeDate(year: 2026, month: 7, day: 20, hour: 0)
        let grid = HeatmapGrid(
            points: [
                ChartPoint(date: inside, count: 3),
                ChartPoint(date: before, count: 10),
                ChartPoint(date: after, count: 10),
            ],
            range: try weekRange(),
            calendar: .utc
        )

        #expect(grid.counts.joined().reduce(0, +) == 3)
    }

    @Test("Block counts sum the hourly cells they span")
    func blockCounts() {
        var counts = [[Int]](repeating: [Int](repeating: 0, count: 24), count: 7)
        counts[2][8] = 3
        counts[2][11] = 4
        counts[2][12] = 5
        let grid = HeatmapGrid(counts: counts)

        #expect(grid.blockCount(day: 2, block: 2, hours: 4) == 7)
        #expect(grid.blockCount(day: 2, block: 3, hours: 4) == 5)
        #expect(grid.blockCount(day: 2, block: 0, hours: 4) == 0)
    }

    @Test("The busiest block sets the maximum")
    func maxBlock() {
        var counts = [[Int]](repeating: [Int](repeating: 0, count: 24), count: 7)
        counts[0][9] = 3
        counts[0][10] = 4
        counts[5][20] = 6
        let grid = HeatmapGrid(counts: counts)

        #expect(grid.maxBlockCount(hours: 4) == 7)
    }

    @Test("An empty grid has no block counts")
    func emptyGrid() throws {
        let grid = HeatmapGrid(points: [], range: try weekRange(), calendar: .utc)

        #expect(grid.maxBlockCount(hours: 4) == 0)
    }

    @Test("The recent range covers whole weeks up to tomorrow")
    func recentRange() throws {
        let now = try makeDate(year: 2026, month: 7, day: 16, hour: 11)
        let range = HeatmapGrid.recentRange(weeks: 4, now: now)

        #expect(range.upperBound == (try makeDate(year: 2026, month: 7, day: 17)))
        #expect(range.lowerBound == (try makeDate(year: 2026, month: 6, day: 19)))
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0) throws -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour)
        return try #require(Calendar.utc.date(from: components))
    }

    private func weekRange() throws -> Range<Date> {
        try makeDate(year: 2026, month: 7, day: 13)..<makeDate(year: 2026, month: 7, day: 20)
    }
}
