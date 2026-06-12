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
struct HomeLogProviderTests {
    let allTime = Date.distantPast..<Date.distantFuture

    @Test("Fetch builds a summary from both matrix record types")
    func fetchBuildsSummary() async throws {
        let database = DatabaseStub()
        database.add(
            makeRecord(type: Int.recordType, name: "login", value: 3),
            makeRecord(type: Int.recordType, name: "Crash", value: 2),
            makeRecord(type: Int.recordType, name: "api_calls", category: "counter", value: 7),
            makeRecord(type: Double.recordType, name: "load_time", category: "timer", value: 0.25)
        )

        let provider = HomeLogProvider()
        await provider.fetchIfNeeded(in: database)
        let summary = try #require(try provider.result?.get())

        #expect(summary.eventCount(in: allTime) == 3)
        #expect(summary.crashCount(in: allTime) == 2)
        #expect(summary.metricCount(in: allTime) == 2)
        #expect(database.readCount(of: Int.recordType) == 1)
        #expect(database.readCount(of: Double.recordType) == 1)
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
        await provider.fetchIfNeeded(in: database)
        let summary = try #require(try provider.result?.get())

        #expect(summary.intMatrices.count == 1)
        #expect(summary.eventCount(in: allTime) == 7)
    }

    // MARK: - Factories

    private func makeRecord(type: String, name: String, category: String? = nil, date: Date = Date(), value: any CKRecordValueProtocol) -> CKRecord {
        let record = CKRecord(recordType: type)
        record["name"] = name
        record["category"] = category
        record["date"] = date
        record["cell_1_00"] = value
        return record
    }
}
