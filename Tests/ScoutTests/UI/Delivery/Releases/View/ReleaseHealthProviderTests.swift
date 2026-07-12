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

    @Test("Builds per-version sessions and crashes from matrices")
    func fetchAggregatesByVersion() async throws {
        let database = DatabaseStub()
        database.add(
            sessionMatrix(version: "2.0", count: 2),
            sessionMatrix(version: "1.0", count: 1),
            crashMatrix(version: "2.0", count: 1)
        )

        let provider = ReleaseHealthProvider()
        await provider.fetchIfNeeded(in: database)
        let releases = try #require(provider.result).get()

        #expect(releases.map(\.id) == ["2.0", "1.0"])
        #expect(releases[0].sessions == 2)
        #expect(releases[0].crashes == 1)
        #expect(releases[0].freeSessions.value == 0.5)
        #expect(releases[0].freeUsers == nil)
        #expect(releases[1].sessions == 1)
        #expect(releases[1].freeSessions.value == 1)
    }

    @Test("Skips session matrices that carry no version")
    func fetchSkipsVersionlessMatrices() async throws {
        let database = DatabaseStub()
        database.add(
            sessionMatrix(version: "3.0", count: 4),
            sessionMatrix(version: nil, count: 9)
        )

        let provider = ReleaseHealthProvider()
        await provider.fetchIfNeeded(in: database)
        let releases = try #require(provider.result).get()

        #expect(releases.map(\.id) == ["3.0"])
        #expect(releases[0].sessions == 4)
    }

    private func sessionMatrix(version: String?, count: Int) -> Record {
        matrix(name: SessionEntry.recordType, version: version, count: count)
    }

    private func crashMatrix(version: String?, count: Int) -> Record {
        matrix(name: CrashEntry.recordType, version: version, count: count)
    }

    private func matrix(name: String, version: String?, count: Int) -> Record {
        Matrix<GridCell<Int>>(
            date: date,
            name: name,
            version: version,
            cells: [GridCell(row: 1, column: 0, value: count)]
        ).record
    }
}
