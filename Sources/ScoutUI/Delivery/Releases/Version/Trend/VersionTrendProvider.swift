//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class VersionTrendProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<VersionTrend>?
    let version: String

    init(_ result: ProviderResult<Output>? = nil, version: String) {
        self.result = result
        self.version = version
    }

    func fetch(in database: SeriesReader) async throws -> VersionTrend {
        let window = Date().trailingTwoWeeks

        async let crashes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: Crash.recordType, bucket: .day, byVersion: true, range: window)
        )
        async let hangs = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: Hang.recordType, bucket: .day, byVersion: true, range: window)
        )
        async let resources = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ResourceException.recordType, bucket: .day, byVersion: true, range: window)
        )

        return try await VersionTrend(
            crashes: crashes.dailyCounts(version: version, window: window),
            hangs: hangs.dailyCounts(version: version, window: window),
            resources: resources.dailyCounts(version: version, window: window)
        )
    }
}
