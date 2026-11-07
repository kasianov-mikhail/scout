//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@MainActor
struct VersionTrendProviderTests {
    private let date = Date().startOfDay

    @Test("Builds daily crash and hang counts of the requested version from series")
    func fetchFiltersSeriesByVersion() async throws {
        let database = DatabaseStub()
        database.add(
            series: series(name: Crash.recordType, version: "2.0", count: 3),
            series(name: Crash.recordType, version: "1.0", count: 5),
            series(name: Hang.recordType, version: "2.0", count: 2)
        )

        let provider = VersionTrendProvider(version: "2.0")
        await provider.fetchLatest(in: database)
        let trend = try #require(provider.result).get()

        #expect(trend.crashes.count == 14)
        #expect(trend.crashes.last?.count == 3)
        #expect(trend.crashes.map(\.count).reduce(0, +) == 3)
        #expect(trend.hangs.map(\.count).reduce(0, +) == 2)
    }

    @Test("Reads series only, never raw incident records")
    func fetchReadsNoRecords() async throws {
        let database = DatabaseStub()
        database.add(series: series(name: Crash.recordType, version: "2.0", count: 1))

        let provider = VersionTrendProvider(version: "2.0")
        await provider.fetchLatest(in: database)

        #expect(database.seriesReadCount == 3)
        #expect(database.readCount(of: Crash.recordType) == 0)
        #expect(database.readCount(of: Hang.recordType) == 0)
        #expect(database.readCount(of: ResourceException.recordType) == 0)
    }

    @Test("A version without incidents gets fourteen empty days")
    func fetchEmptyVersion() async throws {
        let database = DatabaseStub()
        database.add(series: series(name: Crash.recordType, version: "1.0", count: 4))

        let provider = VersionTrendProvider(version: "2.0")
        await provider.fetchLatest(in: database)
        let trend = try #require(provider.result).get()

        #expect(trend.crashes.count == 14)
        #expect(trend.crashes.allSatisfy { $0.count == 0 })
        #expect(trend.resources.allSatisfy { $0.count == 0 })
    }

    private func series(name: String, version: String, count: Int) -> MetricSeries {
        MetricSeries(
            name: name,
            category: nil,
            version: version,
            points: [MetricSeriesPoint(date: date, value: Double(count))]
        )
    }
}
