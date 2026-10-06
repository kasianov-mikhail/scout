//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class ReleaseHealthProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[ReleaseHealth]>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: SeriesReader) async throws -> [ReleaseHealth] {
        let range = Date().trailingYear

        async let sessions = database.lifecycleSeries(
            matching: .sessions(bucket: .day, byVersion: true, range: range)
        )
        async let crashes = database.lifecycleSeries(
            matching: .crashes(bucket: .day, byVersion: true, range: range)
        )
        async let hangs = database.lifecycleSeries(
            matching: .hangs(bucket: .day, byVersion: true, range: range)
        )
        async let installs = database.lifecycleSeries(
            matching: .installs(bucket: .day, byVersion: true, range: range)
        )
        async let crashedInstalls = database.lifecycleSeries(
            matching: .firstCrashes(bucket: .day, byVersion: true, range: range)
        )

        return try await ReleaseSeries(
            sessions: sessions,
            crashes: crashes,
            hangs: hangs,
            installs: installs,
            crashedInstalls: crashedInstalls
        )
        .report(in: range)
    }
}
