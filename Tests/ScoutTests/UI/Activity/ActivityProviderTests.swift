//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import Testing

@testable import Scout

@MainActor
struct ActivityProviderTests {
    @Test("Reads the native series from a Scout server and rebuilds matrices")
    func fetchUsesServerSeries() async throws {
        let database = ServerStub(series: [
            ActiveUserPoint(date: ms(2026, 6, 10), dau: 2, wau: 2, mau: 2),
            ActiveUserPoint(date: ms(2026, 6, 11), dau: 1, wau: 3, mau: 2),
            ActiveUserPoint(date: ms(2026, 7, 1), dau: 0, wau: 0, mau: 5),
        ])

        let provider = ActivityProvider()
        await provider.fetchIfNeeded(in: database)
        let matrices = try #require(try provider.result?.get())

        // One matrix per month: June (all periods) and July (only its MAU cell).
        #expect(matrices.count == 2)

        let daily = matrices.points(on: .daily).sorted()
        let weekly = matrices.points(on: .weekly).sorted()
        let monthly = matrices.points(on: .monthly).sorted()

        // Zero-activity days never become cells.
        #expect(daily.map(\.count) == [2, 1])
        #expect(weekly.map(\.count) == [2, 3])
        #expect(monthly.map(\.count) == [2, 2, 5])

        // Day offsets resolve back to the original dates.
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

/// An `AppDatabase` that also answers the native active-user series, standing
/// in for a Scout server backend.
///
private final class ServerStub: AppDatabase, ActiveUsersReading, @unchecked Sendable {
    let series: [ActiveUserPoint]

    init(series: [ActiveUserPoint]) {
        self.series = series
    }

    func activeUsers(in range: Range<Date>) async throws -> [ActiveUserPoint] {
        series
    }

    func lookup(id: CKRecord.ID, fields: [CKRecord.FieldKey]?) async throws -> CKRecord {
        throw CKError(.unknownItem)
    }

    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func readMore(from cursor: RecordCursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}
