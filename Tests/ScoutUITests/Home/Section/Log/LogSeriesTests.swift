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

struct LogSeriesTests {
    let today = Date().startOfDay

    @Test("Events count everything that is neither a crash nor a hang")
    func events() {
        let report = makeReport(
            series: [
                makeSeries(name: "login", value: 3),
                makeSeries(name: "purchase", value: 4),
                makeSeries(name: CrashEntry.recordType, value: 2),
                makeSeries(name: HangEntry.recordType, value: 1),
            ]
        )

        #expect(report[.events]?.count == 7)
        #expect(report[.crashes]?.count == 2)
        #expect(report[.hangs]?.count == 1)
    }

    @Test("Network counts the status buckets and leaves the latency histogram alone")
    func network() {
        let report = makeReport(
            series: [
                makeSeries(name: "/users", category: "status_2xx", value: 5),
                makeSeries(name: "/users", category: "status_5xx", value: 1),
                makeSeries(name: "/users", category: "timer_le_500", value: 8),
            ]
        )

        #expect(report[.network]?.count == 6)
    }

    @Test("Metrics count distinct reporting series across value flavors")
    func metrics() {
        let report = makeReport(
            series: [
                makeSeries(name: "api_calls", category: "counter", value: 7),
                makeSeries(name: "api_calls", category: "counter", value: 2),
                makeSeries(name: "load_time", category: "timer", value: 1.0),
            ]
        )

        #expect(report[.metrics]?.count == 2)
    }

    @Test("Devices read the period, the previous period and one count per slice")
    func devices() throws {
        let report = makeReport(deviceCounts: [2, 1, 0, 1, 2, 0, 0, 1, 2])
        let devices = try #require(report[.devices])

        #expect(devices.count == 2)
        #expect(devices.series?.values == [0, 1, 2, 0, 0, 1, 2])
    }

    @Test("Devices read as zero when the counts do not match the slices")
    func devicesWithoutCounts() {
        #expect(makeReport(deviceCounts: [])[.devices]?.count == 0)
    }

    @Test("Every category draws a sparkline with one value per slice")
    func sliceCount() throws {
        let report = makeReport(
            series: [makeSeries(name: "login", value: 3)],
            deviceCounts: [1, 0, 1, 0, 0, 0, 0, 0, 0]
        )

        for category in LogCategory.allCases {
            let series = try #require(report[category]?.series)
            #expect(series.values.count == MiniChartSeries.sliceCount)
        }
    }

    private func makeReport(series: [MetricSeries] = [], deviceCounts: [Int] = []) -> [LogCategory: Trend] {
        LogSeries(
            snapshot: LogSnapshot(series: series, deviceCounts: deviceCounts),
            period: .today
        )
        .report
    }

    private func makeSeries(name: String, category: String? = nil, value: Double) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: today.addingTimeInterval(3600), value: value)]
        )
    }
}
