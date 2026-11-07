//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ReleaseHealth: Identifiable {
    let id: String
    let shippedAt: Date?
    let freeSessions: Stability
    let freeUsers: Stability?
    let crashes: Int
    let hangs: Int
    let sessions: Int
    let adoption: Adoption
    let exits: ExitSummary
    let performance: PerformanceComparison
    let resources: ResourceSummary
}

extension ReleaseHealth {
    var subtitle: String {
        var parts = ["\(adoption.formatted) of sessions"]

        if let shippedAt {
            parts.append(DateFormatter.monthDay.string(from: shippedAt))
        }

        return parts.joined(separator: " · ")
    }
}

extension ReleaseHealth: Fixture {
    static let samples: [ReleaseHealth] = {
        let today = Date().startOfDay

        return [
            ReleaseHealth(
                id: "3.2.0",
                shippedAt: today.addingDay(-14),
                freeSessions: 0.9982,
                freeUsers: Stability(0.9991),
                crashes: 14,
                hangs: 9,
                sessions: 48210,
                adoption: 0.62,
                exits: ExitSummary(counts: [.normal: 41200, .memoryPressure: 6100, .memoryLimit: 64, .watchdog: 38, .badAccess: 14, .abnormal: 9]),
                performance: .sample,
                resources: .sample
            ),
            ReleaseHealth(
                id: "3.1.4",
                shippedAt: today.addingDay(-27),
                freeSessions: 0.9967,
                freeUsers: Stability(0.9975),
                crashes: 31,
                hangs: 17,
                sessions: 26110,
                adoption: 0.21,
                exits: ExitSummary(counts: [.normal: 22300, .memoryPressure: 3400, .memoryLimit: 71, .watchdog: 45, .badAccess: 31, .taskTimeout: 12]),
                performance: .sample,
                resources: .sample
            ),
            ReleaseHealth(
                id: "3.1.0",
                shippedAt: today.addingDay(-42),
                freeSessions: 0.9921,
                freeUsers: Stability(0.9943),
                crashes: 58,
                hangs: 26,
                sessions: 12050,
                adoption: 0.10,
                exits: ExitSummary(counts: [.normal: 10100, .memoryPressure: 1700, .memoryLimit: 58, .watchdog: 33, .badAccess: 58, .cpuLimit: 6]),
                performance: .sample,
                resources: .sample
            ),
            ReleaseHealth(
                id: "3.0.2",
                shippedAt: today.addingDay(-58),
                freeSessions: 0.9890,
                freeUsers: Stability(0.9905),
                crashes: 42,
                hangs: 20,
                sessions: 4300,
                adoption: 0.05,
                exits: ExitSummary(counts: [.normal: 3600, .memoryPressure: 610, .memoryLimit: 22, .watchdog: 19, .badAccess: 42]),
                performance: .sample,
                resources: .sample
            ),
            ReleaseHealth(
                id: "2.9.9",
                shippedAt: today.addingDay(-75),
                freeSessions: 0.9710,
                freeUsers: Stability(0.9802),
                crashes: 73,
                hangs: 35,
                sessions: 1820,
                adoption: 0.02,
                exits: ExitSummary(counts: [:]),
                performance: .sample,
                resources: .sample
            ),
        ]
    }()
}
