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

    @Test("Sessions and crashes are counted per version from matrices")
    func testCrashFreeByVersion() {
        let releases = releaseReport(
            sessions: [sessionMatrix("2.0", count: 2), sessionMatrix("1.0", count: 1)],
            crashes: [crashMatrix("2.0", count: 1)],
            installs: [],
            crashedInstalls: [],
            range: range
        )

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

    @Test("Crash-free users come from distinct install markers")
    func testFreeUsersFromInstallMarkers() {
        let releases = releaseReport(
            sessions: [sessionMatrix("2.0", count: 10)],
            crashes: [],
            installs: [installMatrix("2.0", count: 4)],
            crashedInstalls: [crashedInstallMatrix("2.0", count: 1)],
            range: range
        )

        #expect(releases[0].freeUsers?.value == 0.75)
    }

    @Test("Crash trend is bucketed from the matrix cell dates")
    func testCrashTrendFromMatrix() {
        let start = Date(timeIntervalSince1970: 0)

        let crashes = Matrix<GridCell<Int>>(
            date: start,
            name: CrashObject.recordType,
            version: "5.0",
            cells: [
                GridCell(row: 1, column: 0, value: 2),
                GridCell(row: 3, column: 0, value: 3),
            ]
        )

        let releases = releaseReport(
            sessions: [sessionMatrix("5.0", count: 10)],
            crashes: [crashes],
            installs: [],
            crashedInstalls: [],
            range: start..<start.addingTimeInterval(7 * 86_400)
        )

        #expect(releases[0].crashes == 5)
        #expect(releases[0].trend == [2, 0, 3, 0, 0, 0, 0])
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

        let releases = releaseReport(
            sessions: [matrix],
            crashes: [],
            installs: [],
            crashedInstalls: [],
            range: start..<start.addingTimeInterval(86_400)
        )

        #expect(releases.map(\.id) == ["5.0"])
        #expect(releases[0].sessions == 5)
    }

    @Test("No data yields no releases")
    func testEmpty() {
        let releases = releaseReport(sessions: [], crashes: [], installs: [], crashedInstalls: [], range: range)
        #expect(releases.isEmpty)
    }

    @Test("Releases are ordered newest version first, regardless of report order")
    func testSortedByVersion() {
        let releases = releaseReport(
            sessions: [sessionMatrix("3.9", count: 1), sessionMatrix("3.10", count: 1), sessionMatrix("4.0", count: 1)],
            crashes: [],
            installs: [],
            crashedInstalls: [],
            range: range
        )

        #expect(releases.map(\.id) == ["4.0", "3.10", "3.9"])
    }

    private func sessionMatrix(_ version: String, count: Int) -> GridMatrix<Int> {
        matrix(name: SessionObject.recordType, version: version, count: count)
    }

    private func crashMatrix(_ version: String, count: Int) -> GridMatrix<Int> {
        matrix(name: CrashObject.recordType, version: version, count: count)
    }

    private func installMatrix(_ version: String, count: Int) -> GridMatrix<Int> {
        matrix(name: VersionMarker.installName, version: version, count: count)
    }

    private func crashedInstallMatrix(_ version: String, count: Int) -> GridMatrix<Int> {
        matrix(name: VersionMarker.crashName, version: version, count: count)
    }

    private func matrix(name: String, version: String, count: Int) -> GridMatrix<Int> {
        Matrix(
            date: Date(timeIntervalSince1970: 0),
            name: name,
            version: version,
            cells: [GridCell(row: 1, column: 0, value: count)]
        )
    }
}
