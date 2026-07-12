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

    @Test("fetchIfNeeded surfaces database errors")
    func surfacesErrors() async {
        let provider = NetworkProvider()
        await provider.fetchIfNeeded(in: ThrowingDatabaseStub())

        guard case .failure = provider.result else {
            Issue.record("Expected a failure result")
            return
        }
    }

    private func makeSeries(name: String, category: String, points: [(Date, Int)]) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: points.map { date, count in
                MetricSeriesPoint(date: date.millisecondsSince1970, value: .int(count))
            }
        )
    }
}

private final class CategoryDatabaseStub: DatabaseReader, @unchecked Sendable {
    let series: [MetricSeries]

    init(series: [MetricSeries]) {
        self.series = series
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        series.filter { $0.category == category }
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}

private final class ThrowingDatabaseStub: DatabaseReader, @unchecked Sendable {
    struct Failure: Error {}

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        throw Failure()
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        throw Failure()
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw Failure()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        throw Failure()
    }
}
