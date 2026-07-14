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
struct HomeLogProviderTests {
    let allTime = Date.distantPast..<Date.distantFuture

    @Test("Fetch builds matrices from both record types")
    func fetchBuildsMatrices() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(name: "login", value: 3),
            makeRecord(name: "Crash", value: 2),
            makeRecord(name: "api_calls", category: "counter", value: 7),
            makeRecord(name: "load_time", category: "timer", value: 0.25)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        let ints = MatrixSpan(matrices: result.0, range: allTime)
        let doubles = MatrixSpan(matrices: result.1, range: allTime)

        #expect(ints.points { $0 != CrashEntry.recordType }.total == 3)
        #expect(ints.points { $0 == CrashEntry.recordType }.total == 2)
        #expect(ints.series + doubles.series == 2)
        #expect(database.readCount(of: Int.recordType) == 1)
        #expect(database.readCount(of: Double.recordType) == 1)
    }

    @Test("Fetch drops lifecycle matrices, keeping crashes")
    func fetchDropsLifecycle() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(name: "login", value: 3),
            makeRecord(name: "Crash", value: 2),
            makeRecord(name: "Session", value: 5),
            makeRecord(name: "Launch", value: 1)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        #expect(Set(result.0.map(\.name)) == ["login", "Crash"])
    }

    @Test("Records of the same matrix merge into one")
    func mergesDuplicates() async throws {
        let date = Date()
        let database = DatabaseStub()
        database.add(
            makeRecord(name: "login", date: date, value: 3),
            makeRecord(name: "login", date: date, value: 4)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        #expect(result.0.count == 1)
        #expect(MatrixSpan(matrices: result.0, range: allTime).points { $0 != CrashEntry.recordType }.total == 7)
    }

    @Test("Each period fetches its own range and the one before it")
    func fetchesSelectedPeriodAndPrevious() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(name: "recent", date: Date().addingDay(-2).startOfWeek, value: 3),
            makeRecord(name: "previous", date: Date().addingDay(-40).startOfWeek, value: 4),
            makeRecord(name: "old", date: Date().addingDay(-200).startOfWeek, value: 5)
        )

        let provider = HomeLogProvider()
        provider.period = .month
        await provider.fetchIfNeeded(in: database)
        let month = try #require(try provider.result?.get())

        provider.period = .year
        await provider.fetchIfNeeded(in: database)
        let year = try #require(try provider.result?.get())

        #expect(Set(month.0.map(\.name)) == ["recent", "previous"])
        #expect(Set(year.0.map(\.name)) == ["recent", "previous", "old"])
    }

    @Test("Switching periods keeps earlier results cached")
    func cachesResultsPerPeriod() async throws {
        let database = DatabaseStub()
        database.add(makeRecord(name: "login", value: 3))

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        provider.period = .week
        await provider.fetchIfNeeded(in: database)
        provider.period = .today
        await provider.fetchIfNeeded(in: database)

        #expect(database.readCount(of: Int.recordType) == 2)
        #expect(provider.result != nil)
        provider.period = .week
        #expect(provider.result != nil)
    }

    private func makeRecord<T: MetricScalar>(name: String, category: String? = nil, date: Date = Date(), value: T)
        -> Record
    {
        Matrix(
            date: date,
            name: name,
            category: category,
            cells: [GridCell(row: 1, column: 0, value: value)]
        ).record
    }
}
