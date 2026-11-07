//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct ReleaseHealth: Identifiable {
    let id: String
    let freeSessions: Stability
    let freeUsers: Stability?
    let crashes: Int
    let hangs: Int
    let sessions: Int
    let adoption: Adoption
    let shipped: Date?
    let trend: [Int]
    let exits: ExitSummary
    let performance: PerformanceComparison
    let resources: ResourceSummary

    var adoptionLabel: String {
        let share = "\(adoption.formatted) of sessions"
        guard let shipped else {
            return share
        }
        return "\(share) · \(DateFormatter.monthDay.string(from: shipped))"
    }
}
