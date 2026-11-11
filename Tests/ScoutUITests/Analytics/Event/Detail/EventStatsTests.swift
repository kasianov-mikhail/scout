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

struct EventStatsTests {
    private let now = Calendar.utc.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 12))!

    private func makePoint(daysAgo: Double, value: Int) -> ChartPoint<Int> {
        ChartPoint(date: now.addingTimeInterval(-daysAgo * 86_400), value: value)
    }

    @Test("Counts land in their periods") func counts() {
        let stats = EventStats(
            points: [
                makePoint(daysAgo: 0.25, value: 3),
                makePoint(daysAgo: 1, value: 10),
                makePoint(daysAgo: 4, value: 5),
                makePoint(daysAgo: 20, value: 7),
                makePoint(daysAgo: 200, value: 11),
            ],
            now: now
        )

        #expect(stats.today == 3)
        #expect(stats.dayFraction == 0.5)
        #expect(stats.rows.map(\.period) == [.yesterday, .week, .month, .year])
        #expect(stats.rows.map(\.count) == [10, 15, 22, 33])
    }

    @Test("A busy yesterday goes above the usual pace") func aboveUsual() {
        let year = (2...366).map { makePoint(daysAgo: Double($0) - 0.5, value: 1) }
        let stats = EventStats(points: year + [makePoint(daysAgo: 0.75, value: 3)], now: now)

        let yesterday = stats.rows[0]
        #expect(yesterday.count == 4)
        #expect(stats.usual > 1)
        #expect(yesterday.above > 0)
        #expect(stats.rows[3].above == 0)
    }

    @Test("Today is split at the usual pace for the hour") func todayBar() {
        let year = (1...365).map { makePoint(daysAgo: Double($0), value: 2) }
        let stats = EventStats(points: year + [makePoint(daysAgo: 0.1, value: 3)], now: now)

        #expect(stats.today == 3)
        #expect(abs(stats.todayBlue - 0.5) < 0.01)
        #expect(abs(stats.todayAbove - 0.5) < 0.01)
    }

    @Test("No events leave the bars empty") func empty() {
        let stats = EventStats(points: [], now: now)

        #expect(stats.today == 0)
        #expect(stats.usual == 0)
        #expect(stats.todayBlue == 0)
        #expect(stats.todayAbove == 0)
        #expect(stats.rows.allSatisfy { $0.blue == 0 && $0.above == 0 })
    }

    @Test("Scale rounds up to 1, 2, 4, 5 or 10 times a power of ten") func niceCeiling() {
        #expect(EventStats.niceCeiling(0) == 1)
        #expect(EventStats.niceCeiling(3) == 4)
        #expect(EventStats.niceCeiling(4.5) == 5)
        #expect(EventStats.niceCeiling(61) == 100)
        #expect(EventStats.niceCeiling(180) == 200)
    }

    @Test("Labels shorten large numbers") func labels() {
        #expect(EventStats.countLabel(0) == "—")
        #expect(EventStats.countLabel(212) == "212")
        #expect(EventStats.countLabel(9_480) == "9.5K")
        #expect(EventStats.countLabel(118_300) == "118K")
        #expect(EventStats.rateLabel(324.1) == "324")
        #expect(EventStats.rateLabel(5.43) == "5.4")
        #expect(EventStats.rateLabel(0.25) == "0.25")
        #expect(EventStats.rateLabel(0.5) == "0.5")
        #expect(EventStats.rateLabel(0) == "0")
    }
}
