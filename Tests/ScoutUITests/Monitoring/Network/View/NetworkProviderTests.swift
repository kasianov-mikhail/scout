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

@MainActor
@Suite("NetworkProvider")
struct NetworkProviderTests {
    let base = Calendar.current.startOfDay(for: .now)

    @Test("fetchIfNeeded builds a report from latency and status series")
    func fetchesReport() async throws {
        let database = CategoryDatabaseStub(series: [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 10)]),
            makeSeries(name: "GET /a", category: "timer_le_1", points: [(base, 10)]),
            makeSeries(name: "POST /b", category: "status_5xx", points: [(base, 2)]),
            makeSeries(name: "plain_timer", category: "timer_le_1", points: [(base, 9)]),
        ])

        let provider = NetworkProvider()
        await provider.fetchIfNeeded(in: database)

        let report = try #require(try provider.result?.get())
        let range = base..<base.adding(.day)

        #expect(report.endpoints(in: range).map(\.name) == ["GET /a", "POST /b"])
        #expect(report.distributions["GET /a"] != nil)
        #expect(report.distributions["plain_timer"] == nil)
    }

    @Test("fetchIfNeeded requests today's hourly int points in one read")
    func requestsTodayOnce() async throws {
        let database = CategoryDatabaseStub(series: [])

        let provider = NetworkProvider()
        await provider.fetchIfNeeded(in: database)

        let query = try #require(database.queries.first)
        #expect(database.queries.count == 1)
        #expect(query.name == nil)
        #expect(query.category == nil)
        #expect(query.values == .int)
        #expect(query.reduce == .sum)
        #expect(query.range == Period.today.initialRange)
        #expect(query.bucket == .hour)
    }

    @Test("fetchIfNeeded ignores series outside the latency and status categories")
    func ignoresOtherCategories() async throws {
        let network = [
            makeSeries(name: "GET /a", category: "status_2xx", points: [(base, 10)]),
            makeSeries(name: "GET /a", category: "status_4xx", points: [(base, 3)]),
            makeSeries(name: "GET /a", category: "timer_le_100", points: [(base, 13)]),
            makeSeries(name: "POST /b", category: "status_5xx", points: [(base, 2)]),
        ]
        let other = [
            makeSeries(name: "GET /a", category: "recorder_le_10", points: [(base, 7)]),
            makeSeries(name: "GET /a", category: nil, points: [(base, 40)]),
            makeSeries(name: "POST /b", category: "counter_reset", points: [(base, 1)]),
        ]
        let database = CategoryDatabaseStub(series: network + other)

        let provider = NetworkProvider()
        await provider.fetchIfNeeded(in: database)

        let report = try #require(try provider.result?.get())
        let expected = NetworkReport(series: network)
        let range = base..<base.adding(.day)

        #expect(database.queries.count == 1)
        #expect(report.endpoints(in: range).map(\.name) == expected.endpoints(in: range).map(\.name))
        #expect(report.endpoints(in: range).map(\.requests) == expected.endpoints(in: range).map(\.requests))
        #expect(report.summary(in: range) == expected.summary(in: range))
        #expect(report.percentiles(in: range) == expected.percentiles(in: range))
    }

    @Test("fetchIfNeeded surfaces database errors")
    func surfacesErrors() async {
        let provider = NetworkProvider()
        await provider.fetchIfNeeded(in: ThrowingDatabaseStub())

        guard case .failure = provider.result else {
            Issue.record("Expected a failure result")
            return
        }
    }

    private func makeSeries(name: String, category: String?, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date, value: Double(count))
            }
        )
    }
}

private final class CategoryDatabaseStub: DatabaseReader, @unchecked Sendable {
    let series: [MetricSeries]

    private let lock = NSLock()
    private var recorded: [MetricSeriesQuery] = []

    var queries: [MetricSeriesQuery] {
        lock.withLock { recorded }
    }

    init(series: [MetricSeries]) {
        self.series = series
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }

    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        []
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        ranges.map { _ in 0 }
    }

    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        nil
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        lock.withLock { recorded.append(query) }
        return series.filter { query.category == nil || $0.category == query.category }
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}

private final class ThrowingDatabaseStub: DatabaseReader, @unchecked Sendable {
    struct Failure: Error {}

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        throw Failure()
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        throw Failure()
    }

    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        throw Failure()
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        throw Failure()
    }

    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        throw Failure()
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        throw Failure()
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        throw Failure()
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        throw Failure()
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw Failure()
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        throw Failure()
    }
}
