//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ChartPointArrayTests {
    let calendar = Calendar(identifier: .iso8601)

    @Test("Group by hour") func testGroupHour() async throws {
        let today = calendar.startOfDay(for: Date())
        let points = createPoints(for: today)
        let grouped = points.group(by: .hour)

        let expected = [
            1, 2, 3, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
        ]
        #expect(Array(grouped.map(\.count).suffix(24)) == expected)
    }

    @Test("Group by day") func testGroupDay() async throws {
        let yesterday = calendar.startOfDay(for: Date()).addingDay(-1)
        let points = createPoints(for: yesterday)
        let grouped = points.group(by: .day)

        let expected = [
            0, 0, 0, 0, 0, 6, 0,
        ]
        #expect(Array(grouped.map(\.count).suffix(7)) == expected)
    }

    func createPoints(for date: Date) -> [ChartPoint] {
        return [
            ChartPoint(date: date, count: 1),
            ChartPoint(date: date.addingTimeInterval(3600), count: 2),
            ChartPoint(date: date.addingTimeInterval(7200), count: 3),
        ]
    }
}
