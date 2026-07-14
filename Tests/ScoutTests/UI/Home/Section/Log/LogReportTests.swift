//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct LogReportTests {
    let today = Date().startOfDay

    @Test("Events count everything that is neither a crash nor a hang")
    func events() {
        let report = makeReport(
            intMatrices: [
                makeMatrix(name: "login", value: 3),
                makeMatrix(name: "purchase", value: 4),
                makeMatrix(name: CrashEntry.recordType, value: 2),
                makeMatrix(name: HangEntry.recordType, value: 1),
            ]
        )

        #expect(report.summary(for: .events).count == 7)
        #expect(report.summary(for: .crashes).count == 2)
        #expect(report.summary(for: .hangs).count == 1)
    }

    @Test("Network counts the status buckets and leaves the latency histogram alone")
    func network() {
        let report = makeReport(
            intMatrices: [
                makeMatrix(name: "/users", category: "status_2xx", value: 5),
                makeMatrix(name: "/users", category: "status_5xx", value: 1),
                makeMatrix(name: "/users", category: "timer_le_500", value: 8),
            ]
        )

        #expect(report.summary(for: .network).count == 6)
    }

    @Test("Metrics count distinct reporting series across both matrix kinds")
    func metrics() {
        let report = makeReport(
            intMatrices: [
                makeMatrix(name: "api_calls", category: "counter", value: 7),
                makeMatrix(name: "api_calls", category: "counter", value: 2),
            ],
            doubleMatrices: [
                makeMatrix(name: "load_time", category: "timer", value: 1.0)
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
            intMatrices: [makeMatrix(name: "login", value: 3)],
            visits: [DeviceVisit(deviceID: UUID().uuidString, date: today.addingTimeInterval(3600))]
        )

        for category in LogCategory.allCases {
            let series = try #require(report.summary(for: category).series)
            #expect(series.values.count == MiniChartSeries.sliceCount)
        }
    }

    private func makeReport(
        intMatrices: [GridMatrix<Int>] = [],
        doubleMatrices: [GridMatrix<Double>] = [],
        visits: [DeviceVisit] = []
    ) -> LogReport {
        LogReport(
            intMatrices: intMatrices,
            doubleMatrices: doubleMatrices,
            visits: visits,
            period: .today
        )
    }

    private func makeMatrix<T: MetricScalar>(name: String, category: String? = nil, value: T) -> GridMatrix<T> {
        Matrix(
            date: today.addingTimeInterval(3600),
            name: name,
            category: category,
            baseRecord: nil,
            cells: [GridCell(row: 1, column: 0, value: value)]
        )
    }
}
