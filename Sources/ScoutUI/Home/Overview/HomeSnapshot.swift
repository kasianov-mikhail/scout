//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HomeSnapshot {
    let alerts: AlertHistory
    let users: ActiveUsers
    let telemetry: [TelemetryItem]
    let releases: ReleaseAdoption
    let retention: [RetentionWeek]

    static let sample = HomeSnapshot(
        alerts: .sample,
        users: .sample,
        telemetry: TelemetryItem.sample,
        releases: .sample,
        retention: [RetentionWeek].samples
    )
}
