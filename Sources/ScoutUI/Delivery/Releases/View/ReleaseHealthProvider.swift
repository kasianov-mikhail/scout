//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
class ReleaseHealthProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[ReleaseHealth]>?

    init(releases: [ReleaseHealth]? = nil) {
        self.result = releases.map { .success($0) }
    }

    func fetch(in database: DatabaseReader) async throws -> [ReleaseHealth] {
        let range = Calendar.utc.defaultRange

        async let sessions = database.series(matching: query(name: SessionEntry.recordType, in: range))
        async let crashes = database.series(matching: query(name: CrashEntry.recordType, in: range))
        async let hangs = database.series(matching: query(name: HangEntry.recordType, in: range))
        async let installs = database.series(matching: query(name: VersionEntry.recordType, in: range))
        async let crashedInstalls = database.series(matching: query(name: MarkerEntry.crashName, in: range))

        return try await ReleaseSeries(
            sessions: sessions,
            crashes: crashes,
            hangs: hangs,
            installs: installs,
            crashedInstalls: crashedInstalls
        )
        .report(in: range)
    }

    private func query(name: String, in range: Range<Date>) -> SeriesQuery {
        SeriesQuery(name: name, bucket: .day, byVersion: true, range: range)
    }
}
