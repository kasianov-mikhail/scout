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
    let trend: [Int]
}

extension ReleaseHealth: Fixture {
    static let samples: [ReleaseHealth] = [
        ReleaseHealth(
            id: "3.2.0",
            freeSessions: 0.9982,
            freeUsers: Stability(0.9991),
            crashes: 14,
            hangs: 9,
            sessions: 48210,
            adoption: 0.62,
            trend: [3, 5, 4, 6, 4, 7, 5]
        ),
        ReleaseHealth(
            id: "3.1.4",
            freeSessions: 0.9967,
            freeUsers: Stability(0.9975),
            crashes: 31,
            hangs: 17,
            sessions: 26110,
            adoption: 0.21,
            trend: [6, 5, 7, 5, 8, 6, 9]
        ),
        ReleaseHealth(
            id: "3.1.0",
            freeSessions: 0.9921,
            freeUsers: Stability(0.9943),
            crashes: 58,
            hangs: 26,
            sessions: 12050,
            adoption: 0.10,
            trend: [9, 11, 8, 10, 12, 9, 13]
        ),
        ReleaseHealth(
            id: "3.0.2",
            freeSessions: 0.9890,
            freeUsers: Stability(0.9905),
            crashes: 42,
            hangs: 20,
            sessions: 4300,
            adoption: 0.05,
            trend: [12, 10, 14, 11, 9, 8, 7]
        ),
        ReleaseHealth(
            id: "2.9.9",
            freeSessions: 0.9710,
            freeUsers: Stability(0.9802),
            crashes: 73,
            hangs: 35,
            sessions: 1820,
            adoption: 0.02,
            trend: [20, 18, 22, 19, 17, 15, 16]
        ),
    ]
}
