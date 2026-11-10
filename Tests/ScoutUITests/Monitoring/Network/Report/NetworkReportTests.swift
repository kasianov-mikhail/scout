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

@Suite("NetworkReport")
struct NetworkReportTests {
    let base = Date(year: 2026, month: 6, day: 1)

    var range: Range<Date> {
        base..<base.adding(.day)
    }

    @Test("Names with status series or endpoint-like names become endpoints")
    func endpointNames() {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 10)]),
                makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 10)]),
                makeSeries(name: "GET /b", category: "timer_le_1", points: [(base, 5)]),
                makeSeries(name: "plain_timer", category: "timer_le_1", points: [(base, 10)]),
            ], bucket: .day)

        #expect(report.endpoints(in: range).map(\.name) == ["GET /a", "GET /b"])
        #expect(report.distributions.keys.contains("plain_timer") == false)
    }

    @Test("Latency-only endpoints count requests from the histogram")
    func latencyOnlyEndpoint() throws {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /b", category: "timer_le_1", points: [(base, 5)])
            ], bucket: .day)

        let endpoint = try #require(report.endpoints(in: range).first)

        #expect(endpoint.requests == 5)
        #expect(endpoint.successRate == nil)
        #expect(endpoint.p99 != nil)
    }

    @Test("Endpoints carry requests, success rate, and p99 for the range")
    func endpointValues() throws {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 99)]),
                makeSeries(name: "GET /a", category: "status_5xx", points: [(base, 1)]),
                makeSeries(name: "GET /a", category: "timer_le_inf", points: [(base, 100)]),
            ], bucket: .day)

        let endpoint = try #require(report.endpoints(in: range).first)

        #expect(endpoint.requests == 100)
        let successRate = try #require(endpoint.successRate?.value)
        #expect(abs(successRate - 0.99) < 0.000001)
        #expect(try #require(endpoint.p99) > 10)
    }

    @Test("Endpoints without latency series have no p99")
    func endpointWithoutLatency() throws {
        let report = NetworkReport(
            series: [
                makeSeries(name: "POST /b", category: "status_2xx", points: [(base, 5)])
            ], bucket: .day)

        let endpoint = try #require(report.endpoints(in: range).first)

        #expect(endpoint.p99 == nil)
        #expect(endpoint.requests == 5)
    }

    @Test("Endpoints with no requests in the range have no success rate")
    func endpointOutsideRange() throws {
        let outside = base.adding(.day, value: 2)
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(outside, 5)])
            ], bucket: .day)

        let endpoint = try #require(report.endpoints(in: range).first)

        #expect(endpoint.requests == 0)
        #expect(endpoint.successRate == nil)
    }

    @Test("Endpoints sort by requests, then by name")
    func endpointSorting() {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /small", category: "status_2xx", points: [(base, 1)]),
                makeSeries(name: "GET /big", category: "status_2xx", points: [(base, 100)]),
                makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 1)]),
            ], bucket: .day)

        #expect(report.endpoints(in: range).map(\.name) == ["GET /big", "GET /a", "GET /small"])
    }

    @Test("summary combines statuses across endpoints")
    func summary() {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 10)]),
                makeSeries(name: "POST /b", category: "status_4xx", points: [(base, 4)]),
            ], bucket: .day)

        let summary = report.statusBreakdown(range: range)

        #expect(summary.total == 14)
        #expect(summary.counts == [10, 0, 4, 0])
    }

    @Test("percentiles combine latency across endpoints")
    func combinedLatency() throws {
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 1)]),
                makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 100)]),
                makeSeries(name: "POST /b", category: "status_2xx", points: [(base, 1)]),
                makeSeries(name: "POST /b", category: "timer_le_inf", points: [(base, 100)]),
            ], bucket: .day)

        let percentiles = try #require(report.percentiles(in: range))
        #expect(percentiles.p50 <= 0.001)
        #expect(percentiles.p99 > 10)
    }

    @Test("summary counts a weekly bucket that starts before the range")
    func summaryFirstWeekOverlap() throws {
        let lower = Date(year: 2026, month: 6, day: 3)
        let week = Date(year: 2026, month: 5, day: 31)
        let report = NetworkReport(
            series: [
                makeSeries(name: "GET /a", category: "status_2xx", points: [(week, 90), (week.addingDay(7), 10)]),
                makeSeries(name: "GET /a", category: "status_5xx", points: [(week, 10)]),
            ],
            bucket: .week
        )

        let summary = report.summary(in: lower..<lower.addingDay(14))

        #expect(summary.requests == 110)
        let successRate = try #require(summary.successRate?.value)
        #expect(abs(successRate - 100.0 / 110.0) < 0.000001)
    }

    @Test("isEmpty reflects endpoint presence")
    func isEmpty() {
        #expect(NetworkReport(series: [], bucket: .day).isEmpty)
        #expect(
            NetworkReport(series: [makeSeries(name: "plain_timer", category: "timer_le_1", points: [(base, 1)])], bucket: .day)
                .isEmpty)
        #expect(
            !NetworkReport(series: [makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 1)])], bucket: .day).isEmpty)
        #expect(
            !NetworkReport(series: [makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 1)])], bucket: .day).isEmpty)
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
