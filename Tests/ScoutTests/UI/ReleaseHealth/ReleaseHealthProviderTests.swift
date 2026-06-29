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
struct ReleaseHealthProviderTests {
    private let date = Date().addingTimeInterval(-3600)

    @Test("Builds per-version session counts from matrices and attributes crashes")
    func fetchAggregatesByVersion() async throws {
        let launch = UUID()
        let crashedSession = UUID()

        let database = DatabaseStub()
        database.add(
            sessionMatrix(version: "2.0", value: 2),
            sessionMatrix(version: "1.0", value: 1),
            versionRecord(appVersion: "2.0", launchID: launch),
            crashRecord(sessionID: crashedSession, launchID: launch)
        )

        let provider = ReleaseHealthProvider()
        await provider.fetchIfNeeded(in: database)
        let releases = try #require(provider.releases)

        #expect(releases.map(\.id) == ["2.0", "1.0"])
        #expect(releases[0].sessions == 2)
        #expect(releases[0].crashes.count == 1)
        #expect(releases[0].crashFreeSessions.value == 0.5)
        #expect(releases[0].crashFreeUsers == nil)
        #expect(releases[1].sessions == 1)
        #expect(releases[1].crashFreeSessions.value == 1)
    }

    @Test("Skips session matrices that carry no version")
    func fetchSkipsVersionlessMatrices() async throws {
        let database = DatabaseStub()
        database.add(
            sessionMatrix(version: "3.0", value: 4),
            sessionMatrix(version: nil, value: 9)
        )

        let provider = ReleaseHealthProvider()
        await provider.fetchIfNeeded(in: database)
        let releases = try #require(provider.releases)

        #expect(releases.map(\.id) == ["3.0"])
        #expect(releases[0].sessions == 4)
    }

    private func sessionMatrix(version: String?, value: Int) -> Record {
        Matrix<GridCell<Int>>(
            date: date,
            name: SessionObject.recordType,
            version: version,
            cells: [GridCell(row: 1, column: 0, value: value)]
        ).record
    }

    private func versionRecord(appVersion: String, launchID: UUID) -> Record {
        var record = Record(recordType: "Version", recordID: UUID().uuidString)
        record["app_version"] = appVersion
        record["launch_id"] = launchID.uuidString
        record["date"] = date
        return record
    }

    private func crashRecord(sessionID: UUID, launchID: UUID) -> Record {
        var record = Record(recordType: "Crash", recordID: UUID().uuidString)
        record["name"] = "SIGSEGV"
        record["session_id"] = sessionID.uuidString
        record["launch_id"] = launchID.uuidString
        record["install_id"] = UUID().uuidString
        record["date"] = date
        return record
    }
}
