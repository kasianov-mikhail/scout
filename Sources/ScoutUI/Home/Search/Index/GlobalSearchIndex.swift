//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct GlobalSearchIndex {
    let series: [MetricSeries]
    let devices: [DeviceSummary]
    let releases: [ReleaseHealth]
    let crashes: [IncidentGroup<Crash>]
    let hangs: [IncidentGroup<Hang>]

    init?(
        series: [MetricSeries]?, devices: [DeviceSummary]?, releases: [ReleaseHealth]?,
        crashes: [IncidentGroup<Crash>]?, hangs: [IncidentGroup<Hang>]?
    ) {
        guard let series, let devices, let releases, let crashes, let hangs else {
            return nil
        }

        self.series = series
        self.devices = devices
        self.releases = releases
        self.crashes = crashes
        self.hangs = hangs
    }

    static let telemetries: [Telemetry.Export] = [.counter, .floatingCounter, .timer, .recorder, .meter]

    private static let endpointCategories = Set(LatencyBuckets.categories + StatusBuckets.categories)

    private static let reservedNames = MetricSeries.lifecycleNames.union([
        CrashEntry.recordType,
        HangEntry.recordType,
    ])

    func hits(matching query: String) -> [GlobalSearchHit] {
        let text = query.trimmingCharacters(in: .whitespaces)

        guard !text.isEmpty else {
            return []
        }

        func matches(_ name: String) -> Bool {
            name.localizedCaseInsensitiveContains(text)
        }

        func names(where predicate: (MetricSeries) -> Bool) -> [String] {
            Set(series.filter(predicate).map(\.name)).filter(matches).sorted()
        }

        let events = names { $0.category == nil && !Self.reservedNames.contains($0.name) }
            .map { GlobalSearchHit.event(name: $0) }

        let metrics = Self.telemetries.flatMap { telemetry in
            names { $0.category == telemetry.rawValue }
                .map { GlobalSearchHit.metric(name: $0, telemetry: telemetry) }
        }

        let endpoints = names { Self.endpointCategories.contains($0.category ?? "") }
            .map { GlobalSearchHit.endpoint(name: $0) }

        let devices =
            devices
            .filter { matches($0.modelName) }
            .map { GlobalSearchHit.device($0) }

        let releases =
            releases
            .filter { matches($0.id) }
            .map { GlobalSearchHit.release($0) }

        let crashes =
            crashes
            .filter { matches($0.name) }
            .map { GlobalSearchHit.crash($0) }

        let hangs =
            hangs
            .filter { matches($0.name) }
            .map { GlobalSearchHit.hang($0) }

        return events + metrics + endpoints + devices + releases + crashes + hangs
    }
}
