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

struct MetricReadingChartPointsTests {
    private let scale = AlertScale(horizonDate: Date(year: 2026, month: 6, day: 8))

    @Test("Hourly buckets land oldest first in the recent window")
    func recentOrder() {
        let reading = MetricReading(
            points: [
                makePoint(day: 7, hour: 0, count: 5),
                makePoint(day: 7, hour: 23, count: 9),
            ],
            period: scale
        )

        #expect(reading.recent.count == 24)
        #expect(reading.recent.first == 5)
        #expect(reading.recent.last == 9)
    }

    @Test("Points within the same hour sum into one bucket")
    func sameHour() {
        let reading = MetricReading(
            points: [
                makePoint(day: 7, hour: 3, count: 2),
                makePoint(day: 7, hour: 3, count: 3),
            ],
            period: scale
        )

        #expect(reading.recent[3] == 5)
    }

    @Test("Baseline is the median hourly bucket of the previous window")
    func baseline() {
        let points = (0..<24).map { makePoint(day: 6, hour: $0, count: 4) }
        let reading = MetricReading(points: points, period: scale)

        #expect(reading.baseline == 4)
    }

    @Test("An empty previous window carries no baseline to compare against")
    func emptyPrevious() {
        let reading = MetricReading(points: [makePoint(day: 7, hour: 1, count: 8)], period: scale)

        #expect(reading.baseline == 0)
        #expect(reading.reference(for: .baselineFactor(2)) == nil)
    }

    @Test("Crash-free stability is computed per hour")
    func stability() {
        let sessions = (0..<24).map { makePoint(day: 7, hour: $0, count: 10) }
        let reading = MetricReading(
            sessions: sessions,
            crashes: [makePoint(day: 7, hour: 5, count: 1)],
            period: scale
        )

        #expect(reading.recent[5] == 0.9)
        #expect(reading.recent[6] == 1)
    }

    @Test("An idle hour reads as fully stable")
    func idle() {
        let reading = MetricReading(sessions: [], crashes: [], period: scale)

        #expect(reading.recent.allSatisfy { $0 == 1 })
        #expect(reading.baseline == 1)
    }

    @Test("A crashing hour with no sessions reads as fully unstable")
    func crashesWithoutSessions() {
        let reading = MetricReading(
            sessions: [],
            crashes: [makePoint(day: 7, hour: 3, count: 2)],
            period: scale
        )

        #expect(reading.recent[3] == 0)
    }

    private func makePoint(day: Int, hour: Int, count: Int) -> ChartPoint<Int> {
        ChartPoint(date: Date(year: 2026, month: 6, day: day, hour: hour), count: count)
    }
}
