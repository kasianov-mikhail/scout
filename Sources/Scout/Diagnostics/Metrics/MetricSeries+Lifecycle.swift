//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension MetricSeries {
    /// The series names Scout reserves for its automatic lifecycle and service
    /// records — devices, installs, launches, sessions, versions, and the
    /// release-crash marker — rather than diagnostics or custom events.
    ///
    /// These records share the metric-series namespace with custom events, so
    /// surfaces that list custom activity (such as the Home log) exclude them by
    /// name. Owning the set here, in the same layer as the native aggregation
    /// that emits these series, keeps its consumers from each carrying a private
    /// copy that silently drifts as new lifecycle records are added.
    ///
    package static let lifecycleNames: Set<String> = [
        DeviceEntry.recordType,
        InstallEntry.recordType,
        LaunchEntry.recordType,
        SessionEntry.recordType,
        VersionEntry.recordType,
        MarkerEntry.crashName,
    ]

    /// A Boolean value indicating whether the series is one of Scout's reserved
    /// lifecycle or service series rather than a diagnostic or custom event.
    package var isLifecycle: Bool {
        Self.lifecycleNames.contains(name)
    }
}
