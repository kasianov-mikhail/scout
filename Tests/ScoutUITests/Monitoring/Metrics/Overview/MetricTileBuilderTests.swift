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

@Suite("MetricTileBuilder")
struct MetricTileBuilderTests {
    private let now = Date(year: 2026, month: 6, day: 10, hour: 23)
    private let day = Date(year: 2026, month: 6, day: 10)

    @Test("Tiles group by kind, rank by value and keep the list suffixes")
    func tiles() throws {
        let builder = MetricTileBuilder(
            intSeries: [
                makeSeries(name: "checkout.completed", category: "counter", points: [(0.001, 3), (0.002, 4)]),
                makeSeries(name: "http.request.duration", category: "timer_le_1", points: [(0.001, 5)]),
                makeSeries(name: "http.request.duration", category: "timer_le_inf", points: [(0.001, 5)]),
                makeSeries(name: "image.upload_kb", category: "recorder_le_100", points: [(0.001, 5)]),
                makeSeries(name: "image.upload_kb", category: "recorder_le_inf", points: [(0.001, 5)]),
            ],
            floatingSeries: [
                makeSeries(name: "revenue.usd", category: "floating_counter", points: [(0.001, 6.5)])
            ],
            meterSeries: [
                makeSeries(name: "queue_depth", category: "meter", points: [(0.001, 12), (0.002, 14)])
            ],
            range: .today,
            now: now
        )

        let tiles = builder.tiles

        #expect(tiles.map(\.name) == ["checkout.completed", "revenue.usd", "http.request.duration", "image.upload_kb", "queue_depth"])
        #expect(tiles.map(\.suffix) == ["total", "total", "p50", "p50", "latest"])

        let counter = try #require(tiles.first)
        #expect(counter.value == 7)
        #expect(counter.valueLabel == "7")
        #expect(counter.series.count == 12)

        let timer = try #require(tiles.first { $0.name == "http.request.duration" })
        #expect(abs(timer.value - 0.001) < 0.000_001)
        #expect(timer.valueLabel == "1 ms")

        let recorder = try #require(tiles.first { $0.name == "image.upload_kb" })
        #expect(recorder.value == 100)
        #expect(recorder.valueLabel == "100")

        let meter = try #require(tiles.first { $0.name == "queue_depth" })
        #expect(meter.value == 14)
    }

    @Test("Empty metrics are dropped")
    func emptyMetrics() {
        let builder = MetricTileBuilder(
            intSeries: [makeSeries(name: "idle", category: "counter", points: [])],
            floatingSeries: [],
            meterSeries: [makeSeries(name: "absent", category: "meter", points: [])],
            range: .today,
            now: now
        )

        #expect(builder.tiles.isEmpty)
    }

    @Test("Week slices give one non-zero point per day")
    func weekSlices() throws {
        let hours: [Double] = [-138, -114, -90, -66, -42, -18, 6]
        let values: [Double] = [1, 2, 3, 4, 5, 6, 7]
        let points = zip(hours, values).map { ($0, $1) }
        let builder = MetricTileBuilder(
            intSeries: [
                makeSeries(
                    name: "api_calls",
                    category: "counter",
                    points: points
                )
            ],
            floatingSeries: [],
            meterSeries: [],
            range: .week,
            now: now
        )

        let tile = try #require(builder.tiles.first)

        #expect(tile.series == [1, 2, 3, 4, 5, 6, 7])
        #expect(tile.series.allSatisfy { $0 > 0 })
        #expect(tile.value == 28)
    }

    private func makeSeries(name: String, category: String, points: [(Double, Double)]) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: points.map { offset, value in
                MetricSeriesPoint(date: day.addingTimeInterval(offset * .hour), value: value)
            }
        )
    }
}
