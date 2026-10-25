//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

struct TrendTests {
    private let scale = DayScale(horizonDate: Date(year: 2026, month: 6, day: 8))

    @Test("Additive points sum into the count and compare against the previous day")
    func additive() throws {
        let trend = Trend(
            total: [
                makePoint(day: 7, hour: 1, value: 8),
                makePoint(day: 7, hour: 2, value: 4),
                makePoint(day: 6, hour: 1, value: 10),
            ],
            period: scale
        )

        #expect(trend.count == 12)
        #expect(try #require(trend.delta).formatted == "+20%")
        #expect(try #require(trend.series).values.reduce(0, +) == 12)
    }

    @Test("Additive points with an empty previous day carry no delta")
    func additiveWithoutPrevious() {
        let trend = Trend(total: [makePoint(day: 7, hour: 1, value: 8)], period: scale)

        #expect(trend.count == 8)
        #expect(trend.delta == nil)
    }

    @Test("Levels are sampled, not summed, and compared level to level")
    func levels() throws {
        let trend = Trend(
            latest: [
                makeActivity(day: -1, dau: 0, wau: 120),
                makeActivity(day: -2, dau: 0, wau: 100),
                makeActivity(day: -8, dau: 0, wau: 90),
            ],
            period: .week
        )

        #expect(trend.count == 120)
        #expect(try #require(trend.delta).formatted == "+33%")
    }

    @Test("Levels outside the window read as a zero level, not as loading")
    func levelsOutsideWindow() {
        let trend = Trend(latest: [makeActivity(day: -20, dau: 0, wau: 100)], period: .week)

        #expect(trend.count == 0)
        #expect(trend.delta == nil)
    }

    @Test("An empty level series reads as a zero level, not as loading")
    func emptyLevels() throws {
        let trend = Trend(latest: [], period: .week)

        #expect(trend.count == 0)
        #expect(trend.delta == nil)
        #expect(try #require(trend.series).values.allSatisfy { $0 == .zero })
    }

    @Test("Today draws the daily level of each of the last seven days, ending today")
    func today() throws {
        let trend = Trend(latest: dailyLevels, period: .today)

        #expect(trend.count == 7)
        #expect(try #require(trend.series).values == [1, 2, 3, 4, 5, 6, 7])
    }

    @Test("Yesterday draws the daily level of each of the seven days before today")
    func yesterday() throws {
        let trend = Trend(latest: dailyLevels, period: .yesterday)

        #expect(trend.count == 6)
        #expect(try #require(trend.series).values == [100, 1, 2, 3, 4, 5, 6])
    }

    @Test("Distinct counts pass their slices through untouched")
    func distinctCounts() throws {
        let trend = Trend(count: 5, previous: 4, values: [1, 2, 3, 4, 5, 5, 5])

        #expect(trend.count == 5)
        #expect(try #require(trend.delta).formatted == "+25%")
        #expect(try #require(trend.series).values == [1, 2, 3, 4, 5, 5, 5])
    }

    @Test("A loading trend has nothing to draw")
    func loading() {
        #expect(Trend.loading.count == nil)
        #expect(Trend.loading.delta == nil)
        #expect(Trend.loading.series == nil)
    }

    private func makePoint(day: Int, hour: Int, value: Int) -> ChartPoint<Int> {
        ChartPoint(date: Date(year: 2026, month: 6, day: day, hour: hour), value: value)
    }

    private var dailyLevels: [ActivityPoint] {
        [makeActivity(day: -7, dau: 100, wau: 0)] + (-6...0).map { makeActivity(day: $0, dau: 7 + $0, wau: 0) }
    }

    private func makeActivity(day: Int, dau: Int, wau: Int) -> ActivityPoint {
        ActivityPoint(
            date: Date().startOfDay.addingDay(day).millisecondsSince1970,
            dau: dau,
            wau: wau,
            mau: 0
        )
    }
}

private struct DayScale: ChartTimeScale {
    let horizonDate: Date

    var id: Date { horizonDate }
    var rangeComponent: Calendar.Component { .day }
    var pointComponent: Calendar.Component { .hour }
}
