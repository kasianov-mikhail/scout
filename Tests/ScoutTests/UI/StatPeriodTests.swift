//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct StatPeriodTests {
    let calendar = Calendar(identifier: .iso8601)

    @Test("Group by today") func testGroupToday() async throws {
        let today = calendar.startOfDay(for: Date())
        let points = createPoints(for: today)

        let groupedToday = StatPeriod.today.group(points)
        let expected = [
            1, 2, 3, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0
        ]
        #expect(groupedToday.map(\.count) == expected)
    }

    @Test("Group by week") func testGroupWeek() async throws {
        let calendar = Calendar(identifier: .iso8601)
        let yesterday = calendar.startOfDay(for: Date()).addingDay(-1)
        let points = createPoints(for: yesterday)

        let groupedWeek = StatPeriod.week.group(points)
        #expect(groupedWeek.map(\.count) == [0, 0, 0, 0, 0, 0, 6])
    }

    func createPoints(for date: Date) -> [ChartPoint] {
        return [
            ChartPoint(date: date, count: 1),
            ChartPoint(date: date.addingTimeInterval(3600), count: 2),
            ChartPoint(date: date.addingTimeInterval(7200), count: 3),
        ]
    }
}
