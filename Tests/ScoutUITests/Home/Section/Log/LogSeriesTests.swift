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
    let now = Date().startOfDay.addingTimeInterval(8 * 3600)

    @Test("Events count everything that is neither a crash nor a hang")
    func events() {
        let report = makeReport(
            series: [
                makeSeries(name: "login", value: 3),
                makeSeries(name: "purchase", value: 4),
                makeSeries(name: Crash.recordType, value: 2),
                makeSeries(name: Hang.recordType, value: 1),
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

    @Test("Today compares against the same part of yesterday")
    func partialDay() throws {
        let report = makeReport(
            series: [
                makeSeries(name: "login", hour: 1, value: 3),
                makeSeries(name: "login", hour: -23, value: 3),
                makeSeries(name: "login", hour: -12, value: 9),
            ]
        )
        let events = try #require(report[.events])

        #expect(events.count == 3)
        #expect(try #require(events.delta).formatted == "+0%")
    }

    @Test("Today draws the trailing day up to now, with no empty future slices")
    func partialDaySeries() throws {
        let report = makeReport(series: (-16...7).map { makeSeries(name: "login", hour: $0, value: 1) })
        let values = try #require(report[.events]?.series).values

        #expect(values.reduce(0, +) == 24)
        #expect(!values.contains(.zero))
    }

    @Test("Device ranges stop at now and compare against the same part of yesterday")
    func deviceRanges() throws {
        let ranges = Period.today.deviceRanges(now: now)

        #expect(ranges[0] == today..<now)
        #expect(ranges[1] == today.addingDay(-1)..<now.addingDay(-1))
        #expect(try #require(ranges.last).upperBound == now)
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
            period: .today,
            now: now
        )
        .report
    }

    private func makeSeries(name: String, category: String? = nil, hour: Int = 1, value: Double) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: today.addingTimeInterval(TimeInterval(hour) * 3600), value: value)]
        )
    }
}
