//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class ReleaseHealthProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ReleaseHealth]>?

    init(releases: [ReleaseHealth]? = nil) {
        self.result = releases.map { .success($0) }
    }

    func fetch(in database: DatabaseReader) async throws -> [ReleaseHealth] {
        let range = Calendar.utc.defaultRange

        async let sessions: IntMatrices = database.readAll(
            matching: query(name: SessionObject.recordType, in: range)
        )
        async let crashes: IntMatrices = database.readAll(
            matching: query(name: CrashObject.recordType, in: range)
        )
        async let installs: IntMatrices = database.readAll(
            matching: query(name: VersionMarker.installName, in: range)
        )
        async let crashedInstalls: IntMatrices = database.readAll(
            matching: query(name: VersionMarker.crashName, in: range)
        )

        return try await releaseReport(
            sessions: sessions,
            crashes: crashes,
            installs: installs,
            crashedInstalls: crashedInstalls,
            range: range
        )
    }

    private func query(name: String, in range: Range<Date>) -> RecordQuery {
        RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [
                RecordQuery.Filter(field: "name", op: .equals, value: .string(name))
            ]
        )
    }
}

extension ReleaseHealthProvider {
    static func fixture() -> ReleaseHealthProvider {
        ReleaseHealthProvider(releases: ReleaseHealth.samples)
    }
}
