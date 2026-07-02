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
            makeRecord(type: Int.recordType, name: "login", value: 3),
            makeRecord(type: Int.recordType, name: "Crash", value: 2),
            makeRecord(type: Int.recordType, name: "api_calls", category: "counter", value: 7),
            makeRecord(type: Double.recordType, name: "load_time", category: "timer", value: 0.25)
        )

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(for: .today, in: database)
        let result = try #require(try provider.result(for: .today)?.get())

        let ints = MatrixSpan(matrices: result.0, range: allTime)
        let doubles = MatrixSpan(matrices: result.1, range: allTime)

        #expect(ints.total { $0 != CrashObject.recordType } == 3)
        #expect(ints.total { $0 == CrashObject.recordType } == 2)
        #expect(ints.series + doubles.series == 2)
        #expect(database.readCount(of: Int.recordType) == 1)
        #expect(database.readCount(of: Double.recordType) == 1)
    }

    @Test("Fetch drops lifecycle matrices, keeping crashes")
    func fetchDropsLifecycle() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(type: Int.recordType, name: "login", value: 3),
            makeRecord(type: Int.recordType, name: "Crash", value: 2),
            makeRecord(type: Int.recordType, name: "Session", value: 5),
            makeRecord(type: Int.recordType, name: "Launch", value: 1)
        )

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(for: .today, in: database)
        let result = try #require(try provider.result(for: .today)?.get())

        #expect(Set(result.0.map(\.name)) == ["login", "Crash"])
    }

    @Test("Records of the same matrix merge into one")
    func mergesDuplicates() async throws {
        let date = Date()
        let database = DatabaseStub()
        database.add(
            makeRecord(type: Int.recordType, name: "login", date: date, value: 3),
            makeRecord(type: Int.recordType, name: "login", date: date, value: 4)
        )

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(for: .today, in: database)
        let result = try #require(try provider.result(for: .today)?.get())

        #expect(result.0.count == 1)
        #expect(MatrixSpan(matrices: result.0, range: allTime).total { $0 != CrashObject.recordType } == 7)
    }

    @Test("Each period fetches only its own range")
    func fetchesSelectedPeriodOnly() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(type: Int.recordType, name: "recent", date: Date().addingDay(-2).startOfWeek, value: 3),
            makeRecord(type: Int.recordType, name: "old", date: Date().addingDay(-60).startOfWeek, value: 4)
        )

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(for: .month, in: database)
        await provider.fetchIfNeeded(for: .year, in: database)

        let month = try #require(try provider.result(for: .month)?.get())
        let year = try #require(try provider.result(for: .year)?.get())

        #expect(Set(month.0.map(\.name)) == ["recent"])
        #expect(Set(year.0.map(\.name)) == ["recent", "old"])
    }

    @Test("Switching periods keeps earlier results cached")
    func cachesResultsPerPeriod() async throws {
        let database = DatabaseStub()
        database.add(makeRecord(type: Int.recordType, name: "login", value: 3))

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(for: .today, in: database)
        await provider.fetchIfNeeded(for: .week, in: database)
        await provider.fetchIfNeeded(for: .today, in: database)

        #expect(database.readCount(of: Int.recordType) == 2)
        #expect(provider.result(for: .today) != nil)
        #expect(provider.result(for: .week) != nil)
    }

    private func makeRecord(type: String, name: String, category: String? = nil, date: Date = Date(), value: any RecordValueConvertible) -> Record {
        var record = Record(recordType: type, recordID: UUID().uuidString)
        record["name"] = name
        record["category"] = category
        record["date"] = date
        record.fields["cell_1_00"] = value.recordValue
        return record
    }
}
