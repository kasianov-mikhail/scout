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
struct ActivityProviderTests {
    @Test("Returns the native series from a Scout server unchanged")
    func fetchUsesServerSeries() async throws {
        let database = ServerStub(series: [
            ActivityPoint(date: ms(2026, 6, 10), dau: 2, wau: 2, mau: 2),
            ActivityPoint(date: ms(2026, 6, 11), dau: 1, wau: 3, mau: 2),
            ActivityPoint(date: ms(2026, 7, 1), dau: 0, wau: 0, mau: 5),
        ])

        let provider = ActivityProvider()
        await provider.fetchIfNeeded(in: database)
        let series = try #require(try provider.result?.get())

        let daily = series.points(on: .daily).sorted()
        let weekly = series.points(on: .weekly).sorted()
        let monthly = series.points(on: .monthly).sorted()

        // Zero-activity days never become points.
        #expect(daily.map(\.count) == [2, 1])
        #expect(weekly.map(\.count) == [2, 3])
        #expect(monthly.map(\.count) == [2, 2, 5])

        // Millisecond timestamps resolve back to the original dates.
        #expect(daily.first?.date == date(2026, 6, 10))
        #expect(monthly.last?.date == date(2026, 7, 1))
    }

    @Test("Non-server backends still issue the PeriodMatrix query")
    func fetchFallsBackToMatrixQuery() async throws {
        let database = DatabaseStub()

        let provider = ActivityProvider()
        await provider.fetchIfNeeded(in: database)
        _ = try #require(try provider.result?.get())

        #expect(database.readCount(of: PeriodCell<Int>.recordType) == 1)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        DateComponents(calendar: .utc, year: year, month: month, day: day).date!
    }

    private func ms(_ year: Int, _ month: Int, _ day: Int) -> Int64 {
        Int64((date(year, month, day).timeIntervalSince1970 * 1000).rounded())
    }
}

/// A `DatabaseReader` that returns a native active-user series, standing in for a
/// Scout server backend.
///
private final class ServerStub: DatabaseReader, @unchecked Sendable {
    let series: [ActivityPoint]

    init(series: [ActivityPoint]) {
        self.series = series
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        series
    }

    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
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
