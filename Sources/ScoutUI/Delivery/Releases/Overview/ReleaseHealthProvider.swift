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
            matching: LifecycleSeriesQuery(name: SessionEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        async let crashes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: CrashEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        async let hangs = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: HangEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        async let installs = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: MarkerEntry.installName, bucket: .day, byVersion: true, range: range)
        )
        async let crashedInstalls = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: MarkerEntry.crashName, bucket: .day, byVersion: true, range: range)
        )
        async let exits = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ExitReason.metricName, bucket: .day, byVersion: true, range: range)
        )

        async let launches = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: PerformanceMetric.launchTime.rawValue, bucket: .day, byVersion: true, range: range)
        )
        async let hangTimes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: PerformanceMetric.hangTime.rawValue, bucket: .day, byVersion: true, range: range)
        )
        async let foregroundTimes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: PerformanceMetric.foregroundTime.rawValue, bucket: .day, byVersion: true, range: range)
        )
        async let resources = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: ResourceEntry.recordType, bucket: .day, byVersion: true, range: range)
        )
        async let peakMemory = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: PerformanceMetric.peakMemory.rawValue, bucket: .day, byVersion: true, range: range)
        )

        return try await ReleaseSeries(
            sessions: sessions,
            crashes: crashes,
            hangs: hangs,
            installs: installs,
            crashedInstalls: crashedInstalls,
            exits: exits,
            performance: launches + hangTimes + foregroundTimes + peakMemory,
            resources: resources
        )
        .report(in: range)
    }
}
