//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
struct HomeLogProviderTests {
    let allTime = Date.distantPast..<Date.distantFuture

    @Test("Fetch reads events, crashes, hangs and metrics in one pass")
    func fetchSweepsAllFlavors() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(name: "login", value: 3),
            makeSeries(name: "Crash", value: 2),
            makeSeries(name: "api_calls", category: "counter", value: 7),
            makeSeries(name: "load_time", category: "timer", value: 0.25)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        let span = SeriesSpan(series: result, range: allTime)

        #expect(span.points { $0 != CrashEntry.recordType }.total == 3)
        #expect(span.points { $0 == CrashEntry.recordType }.total == 2)
        #expect(span.metricCount == 2)
        #expect(database.seriesReadCount == 4)
    }

    @Test("Fetch reads crashes but not sessions from the lifecycle counters")
    func fetchSkipsSessions() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(name: "login", value: 3),
            makeSeries(name: "Crash", value: 2),
            makeSeries(name: "Session", value: 5)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        #expect(Set(result.map(\.name)) == ["login", "Crash"])
    }

    @Test("Fetch never reads the release markers, so they never count as events")
    func fetchSkipsMarkers() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(name: "login", value: 3),
            makeSeries(name: VersionEntry.recordType, value: 1),
            makeSeries(name: MarkerEntry.crashName, value: 1)
        )

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        let result = try #require(try provider.result?.get())

        #expect(Set(result.map(\.name)) == ["login"])
    }

    @Test("Each period fetches its own range and the one before it")
    func fetchesSelectedPeriodAndPrevious() async throws {
        let database = DatabaseStub()
        database.add(
            series: makeSeries(name: "recent", date: Date().addingDay(-2), value: 3),
            makeSeries(name: "previous", date: Date().addingDay(-40), value: 4),
            makeSeries(name: "old", date: Date().addingDay(-200), value: 5)
        )

        let provider = HomeLogProvider()
        provider.period = .month
        await provider.fetchIfNeeded(in: database)
        let month = try #require(try provider.result?.get())

        provider.period = .year
        await provider.fetchIfNeeded(in: database)
        let year = try #require(try provider.result?.get())

        #expect(Set(month.map(\.name)) == ["recent", "previous"])
        #expect(Set(year.map(\.name)) == ["recent", "previous", "old"])
    }

    @Test("Switching periods keeps earlier results cached")
    func cachesResultsPerPeriod() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "login", value: 3))

        let provider = HomeLogProvider()
        provider.period = .today
        await provider.fetchIfNeeded(in: database)
        provider.period = .week
        await provider.fetchIfNeeded(in: database)
        provider.period = .today
        await provider.fetchIfNeeded(in: database)

        #expect(database.seriesReadCount == 8)
        #expect(provider.result != nil)
        provider.period = .week
        #expect(provider.result != nil)
    }

    @Test("A fetch that finishes after a period switch never fills the new period's slot")
    func staleFetchSkipsSwitchedPeriod() async throws {
        let database = DatabaseStub()
        database.add(series: makeSeries(name: "login", value: 3))
        let gate = Gate()
        database.gate = gate

        let provider = HomeLogProvider()
        provider.period = .today

        let inFlight = Task { await provider.fetchLatest(in: database) }
        for _ in 0..<10 {
            await Task.yield()
        }

        provider.period = .week
        gate.open()
        _ = await inFlight.value

        #expect(provider.result == nil)
        provider.period = .today
        #expect(provider.result == nil)

        provider.period = .week
        await provider.fetchIfNeeded(in: database)
        #expect(try provider.result?.get() != nil)
    }

    private func makeSeries(name: String, category: String? = nil, date: Date = Date(), value: Double) -> MetricSeries {
        MetricSeries(
            name: name,
            category: category,
            points: [MetricSeriesPoint(date: date, value: value)]
        )
    }
}
