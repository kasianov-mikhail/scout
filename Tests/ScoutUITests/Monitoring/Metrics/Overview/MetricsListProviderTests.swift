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

@MainActor
@Suite("MetricsListProvider")
struct MetricsListProviderTests {
    private let now = Date(year: 2026, month: 6, day: 10, hour: 9)

    @Test("Sparkline slices stop at the current moment")
    func sparklineSkipsFutureSlices() async throws {
        let database = ServerStub(metrics: [
            MetricSeries(
                name: "api_calls",
                category: "counter",
                points: [
                    MetricSeriesPoint(date: Date(year: 2026, month: 6, day: 10, hour: 0, minute: 30), value: 1),
                    MetricSeriesPoint(date: Date(year: 2026, month: 6, day: 10, hour: 8, minute: 40), value: 2),
                ]
            ),
            MetricSeries(
                name: "queue_depth",
                category: "meter",
                points: [
                    MetricSeriesPoint(date: Date(year: 2026, month: 6, day: 10, hour: 8, minute: 50), value: 7)
                ]
            ),
        ])
        let provider = MetricsListProvider(range: .today, now: { now })

        let tiles = try await provider.fetch(in: database)

        let counter = try #require(tiles.first { $0.name == "api_calls" })
        #expect(counter.value == 3)
        #expect(counter.series == [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2])

        let meter = try #require(tiles.first { $0.name == "queue_depth" })
        #expect(meter.value == 7)
        #expect(meter.series.last == 7)
    }
}
