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

struct ReleaseReportTests {
    private let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 700_000)

    @Test("Sessions and crashes are counted per version from series")
    func testCrashFreeByVersion() {
        let releases = ReleaseSeries(
            sessions: [sessionSeries("2.0", count: 2), sessionSeries("1.0", count: 1)],
            crashes: [crashSeries("2.0", count: 1)],
            hangs: [],
            installs: [],
            crashedInstalls: []
        )
        .report(in: range)

        #expect(releases.map(\.id) == ["2.0", "1.0"])

        let latest = releases[0]
        #expect(latest.sessions == 2)
        #expect(latest.crashes == 1)
        #expect(latest.freeSessions.value == 0.5)
        #expect(latest.freeUsers == nil)
        #expect(abs(latest.adoption.value - 2.0 / 3.0) < 1e-9)

        let previous = releases[1]
        #expect(previous.sessions == 1)
        #expect(previous.crashes == 0)
        #expect(previous.freeSessions.value == 1)
        #expect(abs(previous.adoption.value - 1.0 / 3.0) < 1e-9)
    }

    @Test("Hangs are counted per version from series")
    func testHangsByVersion() {
        let releases = ReleaseSeries(
            sessions: [sessionSeries("2.0", count: 2)],
            crashes: [],
            hangs: [hangSeries("2.0", count: 3)],
            installs: [],
            crashedInstalls: []
        )
        .report(in: range)

        #expect(releases[0].hangs == 3)
    }

    @Test("Crash-free users come from install and first-crash counts")
    func testFreeUsersFromInstallCounts() {
        let releases = ReleaseSeries(
            sessions: [sessionSeries("2.0", count: 10)],
            crashes: [],
            hangs: [],
            installs: [installSeries("2.0", count: 4)],
            crashedInstalls: [crashedInstallSeries("2.0", count: 1)]
        )
        .report(in: range)

        #expect(releases[0].freeUsers?.value == 0.75)
    }

    @Test("Crash trend is bucketed from the point dates")
    func testCrashTrendFromPoints() {
        let start = Date(timeIntervalSince1970: 0)

        let crashes = MetricSeries(
            name: CrashEntry.recordType,
            category: nil,
            version: "5.0",
            points: [
                MetricSeriesPoint(date: start.millisecondsSince1970, value: .int(2)),
                MetricSeriesPoint(date: start.addingTimeInterval(2 * 86_400).millisecondsSince1970, value: .int(3)),
            ]
        )

        let releases = ReleaseSeries(
            sessions: [sessionSeries("5.0", count: 10)],
            crashes: [crashes],
            hangs: [],
            installs: [],
            crashedInstalls: []
        )
        .report(in: start..<start.addingTimeInterval(7 * 86_400))

        #expect(releases[0].crashes == 5)
        #expect(releases[0].trend == [2, 0, 3, 0, 0, 0, 0])
    }

    @Test("Session points outside the range are excluded from the count")
    func testSessionPointsCountedInRange() {
        let start = Date(timeIntervalSince1970: 0)

        let sessions = MetricSeries(
            name: SessionEntry.recordType,
            category: nil,
            version: "5.0",
            points: [
                MetricSeriesPoint(date: start.millisecondsSince1970, value: .int(5)),
                MetricSeriesPoint(date: start.addingTimeInterval(2 * 86_400).millisecondsSince1970, value: .int(7)),
            ]
        )

        let releases = ReleaseSeries(sessions: [sessions], crashes: [], hangs: [], installs: [], crashedInstalls: [])
            .report(in: start..<start.addingTimeInterval(86_400))

        #expect(releases.map(\.id) == ["5.0"])
        #expect(releases[0].sessions == 5)
    }

    @Test("Series without a version are left out of the report")
    func testUnversionedSeriesIgnored() {
        let unversioned = MetricSeries(
            name: SessionEntry.recordType,
            category: nil,
            points: [MetricSeriesPoint(date: range.lowerBound.millisecondsSince1970, value: .int(5))]
        )

        let releases = ReleaseSeries(sessions: [unversioned], crashes: [], hangs: [], installs: [], crashedInstalls: [])
            .report(in: range)

        #expect(releases.isEmpty)
    }

    @Test("No data yields no releases")
    func testEmpty() {
        let releases = ReleaseSeries(sessions: [], crashes: [], hangs: [], installs: [], crashedInstalls: [])
            .report(in: range)
        #expect(releases.isEmpty)
    }

    @Test("Releases are ordered newest version first, regardless of report order")
    func testSortedByVersion() {
        let releases = ReleaseSeries(
            sessions: [
                sessionSeries("3.9", count: 1), sessionSeries("3.10", count: 1), sessionSeries("4.0", count: 1),
            ],
            crashes: [],
            hangs: [],
            installs: [],
            crashedInstalls: []
        )
        .report(in: range)

        #expect(releases.map(\.id) == ["4.0", "3.10", "3.9"])
    }

    private func sessionSeries(_ version: String, count: Int) -> MetricSeries {
        series(name: SessionEntry.recordType, version: version, count: count)
    }

    private func crashSeries(_ version: String, count: Int) -> MetricSeries {
        series(name: CrashEntry.recordType, version: version, count: count)
    }

    private func hangSeries(_ version: String, count: Int) -> MetricSeries {
        series(name: HangEntry.recordType, version: version, count: count)
    }

    private func installSeries(_ version: String, count: Int) -> MetricSeries {
        series(name: VersionEntry.recordType, version: version, count: count)
    }

    private func crashedInstallSeries(_ version: String, count: Int) -> MetricSeries {
        series(name: MarkerEntry.crashName, version: version, count: count)
    }

    private func series(name: String, version: String, count: Int) -> MetricSeries {
        MetricSeries(
            name: name,
            category: nil,
            version: version,
            points: [MetricSeriesPoint(date: Date(timeIntervalSince1970: 0).millisecondsSince1970, value: .int(count))]
        )
    }
}
