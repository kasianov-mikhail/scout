//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

@Suite("StatusDistribution")
struct StatusDistributionTests {
    let base = Date(year: 2026, month: 6, day: 1)

    @Test("Builds breakdowns from status series and ignores foreign categories")
    func seriesInit() throws {
        let distribution = StatusDistribution(series: [
            makeSeries(category: "status_2xx", points: [(base, 90)]),
            makeSeries(category: "status_5xx", points: [(base, 10)]),
            makeSeries(category: "timer_le_1", points: [(base, 9)]),
            makeSeries(category: "counter", points: [(base, 9)]),
        ])

        #expect(distribution.breakdowns.count == 1)

        let breakdown = try #require(distribution.breakdowns[base])
        #expect(breakdown.counts == [90, 0, 0, 10])
    }

    @Test("summary combines breakdowns within the range only")
    func summaryRange() {
        let inside = base
        let outside = base.adding(.day, value: 2)
        let distribution = StatusDistribution(series: [
            makeSeries(category: "status_2xx", points: [(inside, 50), (outside, 100)]),
            makeSeries(category: "status_4xx", points: [(inside, 5)]),
        ])

        let summary = distribution.summary(in: base..<base.adding(.day))

        #expect(summary.total == 55)
        #expect(summary.counts == [50, 0, 5, 0])
    }

    @Test("isEmpty reflects total counts")
    func isEmpty() {
        #expect(StatusDistribution(series: []).isEmpty)
        #expect(!StatusDistribution(series: [makeSeries(category: "status_2xx", points: [(base, 1)])]).isEmpty)
    }

    private func makeSeries(category: String, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: "GET /v1/events",
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date.millisecondsSince1970, value: .int(count))
            }
        )
    }
}
