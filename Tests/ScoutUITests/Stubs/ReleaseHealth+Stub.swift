//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import ScoutUI

extension ReleaseHealth {
    @discardableResult static func stub(version: String, shipped: Date? = nil) -> ReleaseHealth {
        ReleaseHealth(
            id: version,
            freeSessions: 1.0,
            freeUsers: nil,
            crashes: 0,
            hangs: 0,
            sessions: 1,
            adoption: 1.0,
            shipped: shipped,
            trend: [],
            exits: ExitSummary(counts: [:]),
            performance: PerformanceComparison(current: PerformanceSummary(), previous: nil),
            resources: ResourceSummary(counts: [:])
        )
    }
}
