//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@MainActor
struct MetricsProviderTests {
    @Test("Returns the native series from a Scout server unchanged")
    func fetchUsesServerSeries() async throws {
        let database = MetricsServerStub(series: [
            MetricSeries(
                name: "api_calls",
                category: "counter",
                points: [
                    MetricSeriesPoint(date: ms(2026, 6, 10, 9), value: .int(2)),
                    MetricSeriesPoint(date: ms(2026, 6, 10, 10), value: .int(3)),
                    MetricSeriesPoint(date: ms(2026, 6, 17, 9), value: .int(1)),
                ]
            ),
            MetricSeries(
                name: "errors",
                category: "counter",
                points: [
                    MetricSeriesPoint(date: ms(2026, 6, 10, 9), value: .int(4))
                ]
            ),
        ])

        let provider = MetricsProvider<Int>(telemetry: .counter)
        await provider.fetchIfNeeded(in: database)
        let series = try #require(try provider.result?.get())

        let groups: [PointGroup<Int>] = series.pointGroups()
        #expect(Set(groups.map(\.name)) == ["api_calls", "errors"])

        let calls = try #require(groups.first { $0.name == "api_calls" })
        // Points span two weeks but flatten under the one name.
        #expect(calls.points.map(\.count).sorted() == [1, 2, 3])
        // The cell position round-trips back to the original hour.
        #expect(calls.points.contains { $0.date == date(2026, 6, 10, 9) })
        #expect(calls.points.contains { $0.date == date(2026, 6, 17, 9) })

        let errors = try #require(groups.first { $0.name == "errors" })
        #expect(errors.points.map(\.count) == [4])
    }

    @Test("Non-server backends still issue the matrix query")
    func fetchFallsBackToMatrixQuery() async throws {
        let database = DatabaseStub()

        let provider = MetricsProvider<Int>(telemetry: .counter)
        await provider.fetchIfNeeded(in: database)
        _ = try #require(try provider.result?.get())

        #expect(database.readCount(of: Int.recordType) == 1)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date {
        DateComponents(calendar: .utc, year: year, month: month, day: day, hour: hour).date!
    }

    private func ms(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Int64 {
        Int64((date(year, month, day, hour).timeIntervalSince1970 * 1000).rounded())
    }
}

/// A `DatabaseReader` that returns a native metric series, standing in for a
/// Scout server backend.
///
private final class MetricsServerStub: DatabaseReader, @unchecked Sendable {
    let series: [MetricSeries]

    init(series: [MetricSeries]) {
        self.series = series
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        series
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}
