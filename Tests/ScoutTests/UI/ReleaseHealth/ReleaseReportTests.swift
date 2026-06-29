//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ReleaseReportTests {
    private let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 700_000)

    @Test("Crashes join to versions through their launch IDs; sessions come from per-version matrices")
    func testCrashFreeByVersion() {
        let launch = UUID()
        let crashedSession = UUID()

        let versions = [
            Version.stub(appVersion: "2.0", buildNumber: "10", launchID: launch, date: Date(timeIntervalSince1970: 600_000))
        ]

        let crashes = [
            Crash.stub(
                sessionID: crashedSession,
                launchID: launch,
                installID: UUID(),
                date: Date(timeIntervalSince1970: 500_000)
            )
        ]

        let releases = ReleaseReport(
            sessionMatrices: [sessionMatrix("2.0", count: 2), sessionMatrix("1.0", count: 1)],
            crashes: crashes,
            versions: versions,
            range: range
        ).releases

        #expect(releases.map(\.id) == ["2.0", "1.0"])

        let latest = releases[0]
        #expect(latest.sessions == 2)
        #expect(latest.crashes.count == 1)
        #expect(latest.crashFreeSessions.value == 0.5)
        #expect(latest.crashFreeUsers == nil)
        #expect(abs(latest.adoption.value - 2.0 / 3.0) < 1e-9)

        let previous = releases[1]
        #expect(previous.sessions == 1)
        #expect(previous.crashes.count == 0)
        #expect(previous.crashFreeSessions.value == 1)
        #expect(abs(previous.adoption.value - 1.0 / 3.0) < 1e-9)
    }

    @Test("Crashes on unknown launches are ignored")
    func testUnknownLaunchIgnored() {
        let versions = [Version.stub(appVersion: "3.0", launchID: UUID())]
        let crashes = [Crash.stub(launchID: UUID())]

        let releases = ReleaseReport(
            sessionMatrices: [sessionMatrix("3.0", count: 1)],
            crashes: crashes,
            versions: versions,
            range: range
        ).releases

        #expect(releases.count == 1)
        #expect(releases[0].sessions == 1)
        #expect(releases[0].crashes.count == 0)
        #expect(releases[0].crashFreeSessions.value == 1)
    }

    @Test("Session matrix cells outside the range are excluded from the count")
    func testSessionMatricesCountedInRange() {
        let start = Date(timeIntervalSince1970: 0)

        let matrix = Matrix<GridCell<Int>>(
            date: start,
            name: SessionObject.recordType,
            version: "5.0",
            cells: [
                GridCell(row: 1, column: 0, value: 5),
                GridCell(row: 3, column: 0, value: 7),
            ]
        )

        let releases = ReleaseReport(
            sessionMatrices: [matrix],
            crashes: [],
            versions: [],
            range: start..<start.addingTimeInterval(86_400)
        ).releases

        #expect(releases.map(\.id) == ["5.0"])
        #expect(releases[0].sessions == 5)
    }

    @Test("No data yields no releases")
    func testEmpty() {
        let releases = ReleaseReport(sessionMatrices: [], crashes: [], versions: [], range: range).releases
        #expect(releases.isEmpty)
    }

    @Test("Releases are ordered newest version first, regardless of report order")
    func testSortedByVersion() {
        let releases = ReleaseReport(
            sessionMatrices: [sessionMatrix("2.5", count: 1), sessionMatrix("4.0", count: 1), sessionMatrix("2.6", count: 1)],
            crashes: [],
            versions: [],
            range: range
        ).releases

        #expect(releases.map(\.id) == ["4.0", "2.6", "2.5"])
    }

    private func sessionMatrix(_ version: String, count: Int) -> GridMatrix<Int> {
        Matrix(
            date: Date(timeIntervalSince1970: 0),
            name: SessionObject.recordType,
            version: version,
            cells: [GridCell(row: 1, column: 0, value: count)]
        )
    }
}
