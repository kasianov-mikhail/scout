//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

@Suite("Network ledgers")
struct NetworkLedgerTests {
    let base = Date(year: 2026, month: 6, day: 1)
    let now = Date(year: 2026, month: 6, day: 1, hour: 3, minute: 30)

    @Test("Hourly rows sum statuses and latency in each hour")
    func hourlyRows() throws {
        let report = NetworkReport(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 10)]),
            makeSeries(name: "GET /a", category: "status_4xx", points: [(base, 1)]),
            makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 11)]),
            makeSeries(name: "GET /a", category: "timer_le_100", points: [(base.adding(.hour), 20)]),
        ])

        let rows = report.rows(name: "GET /a", range: base..<base.addingDay(), component: .hour, now: now)

        #expect(rows.map(\.date) == [base.adding(.hour, value: 3), base.adding(.hour, value: 2), base.adding(.hour), base])
        #expect(rows.map(\.requests) == [0, 0, 20, 11])

        let latencyOnly = try #require(rows.dropFirst(2).first)
        #expect(latencyOnly.successRate == nil)
        #expect(latencyOnly.p99 != nil)

        #expect(abs((rows[3].successRate?.value ?? 0) - 10.0 / 11.0) < 0.000001)
        #expect(rows[0].isCurrent)
    }

    @Test("Day rows sum hourly points and mark today")
    func dayRows() throws {
        let yesterday = base.addingDay(-1)
        let report = NetworkReport(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(yesterday, 3), (base, 7)]),
            makeSeries(name: "GET /a", category: "status_5xx", points: [(base, 1)]),
            makeSeries(name: "GET /a", category: "timer_le_1", points: [(yesterday, 3), (base, 8)]),
        ])

        let rows = report.rows(name: "GET /a", range: yesterday..<base.addingDay(), component: .day, now: now)

        #expect(rows.map(\.date) == [base, yesterday])
        #expect(rows.map(\.requests) == [8, 3])

        let today = try #require(rows.first)
        #expect(today.isCurrent)
        #expect(abs((today.successRate?.value ?? 0) - 7.0 / 8.0) < 0.000001)

        #expect(rows[1].isCurrent == false)
        #expect(rows[1].successRate?.value == 1.0)
    }

    @Test("Month rows combine days in the same month")
    func monthRows() {
        let may = Date(year: 2026, month: 5, day: 20)
        let reports = NetworkReport(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(may, 4), (base, 5), (base.addingDay(2), 6)])
        ])

        let rows = reports.rows(name: "GET /a", range: may..<base.addingDay(3), component: .month, now: now)

        #expect(rows.map(\.date) == [base.startOfMonth, may.startOfMonth])
        #expect(rows.map(\.requests) == [11, 4])
        #expect(rows[0].isCurrent)
    }

    @Test("Summary counts every endpoint and uses the combined p99")
    func summary() throws {
        let report = NetworkReport(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 9)]),
            makeSeries(name: "GET /a", category: "status_5xx", points: [(base, 1)]),
            makeSeries(name: "GET /a", category: "timer_le_100", points: [(base, 10)]),
            makeSeries(name: "POST /b", category: "status_2xx", points: [(base, 20)]),
        ])

        let summary = report.summary(in: base..<base.addingDay())

        #expect(summary.requests == 30)
        #expect(summary.endpoints == 2)
        #expect(abs((summary.successRate?.value ?? 0) - 29.0 / 30.0) < 0.000001)
        #expect(try #require(summary.p99) > 0)
    }

    private func makeSeries(name: String, category: String, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date, value: Double(count))
            }
        )
    }
}
