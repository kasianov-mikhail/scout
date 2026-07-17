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

struct LogReportTests {
    let today = Date().startOfDay

    @Test("Events count everything that is neither a crash nor a hang")
    func events() {
        let report = makeReport(
            series: [
                makeSeries(name: "login", value: .int(3)),
                makeSeries(name: "purchase", value: .int(4)),
                makeSeries(name: CrashEntry.recordType, value: .int(2)),
                makeSeries(name: HangEntry.recordType, value: .int(1)),
            ]
        )

        #expect(report.summary(for: .events).count == 7)
        #expect(report.summary(for: .crashes).count == 2)
        #expect(report.summary(for: .hangs).count == 1)
    }

    @Test("Network counts the status buckets and leaves the latency histogram alone")
    func network() {
        let report = makeReport(
            series: [
                makeSeries(name: "/users", category: "status_2xx", value: .int(5)),
                makeSeries(name: "/users", category: "status_5xx", value: .int(1)),
                makeSeries(name: "/users", category: "timer_le_500", value: .int(8)),
            ]
        )

        #expect(report.summary(for: .network).count == 6)
    }

    @Test("Metrics count distinct reporting series across value flavors")
    func metrics() {
        let report = makeReport(
            series: [
                makeSeries(name: "api_calls", category: "counter", value: .int(7)),
                makeSeries(name: "api_calls", category: "counter", value: .int(2)),
                makeSeries(name: "load_time", category: "timer", value: .double(1.0)),
            ]
        )

        #expect(report.summary(for: .metrics).count == 2)
    }

    @Test("Devices count the distinct devices seen in the period")
    func devices() {
        let device = UUID().uuidString
        let report = makeReport(
            visits: [
                DeviceVisit(deviceID: device, date: today.addingTimeInterval(3600)),
                DeviceVisit(deviceID: device, date: today.addingTimeInterval(7200)),
                DeviceVisit(deviceID: UUID().uuidString, date: today.addingTimeInterval(7200)),
                DeviceVisit(deviceID: UUID().uuidString, date: today.addingTimeInterval(-7 * 86400)),
            ]
        )

        #expect(report.summary(for: .devices).count == 2)
    }

    @Test("Every category draws a sparkline with one value per slice")
    func sliceCount() throws {
        let report = makeReport(
            series: [makeSeries(name: "login", value: .int(3))],
            visits: [DeviceVisit(deviceID: UUID().uuidString, date: today.addingTimeInterval(3600))]
        )

        for category in LogCategory.allCases {
            let series = try #require(report.summary(for: category).series)
            #expect(series.values.count == MiniChartSeries.sliceCount)
        }
    }

    private func makeReport(series: [MetricSeries] = [], visits: [DeviceVisit] = []) -> LogReport {
        LogReport(
            series: series,
            visits: visits,
            period: .today
        )
    }

    private func makeSeries(name: String, category: String? = nil, value: MetricValue) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: today.addingTimeInterval(3600).millisecondsSince1970, value: value)]
        )
    }
}
