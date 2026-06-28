//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ReleaseHealth: Identifiable {
    let version: String
    let build: String
    let crashFreeSessions: Double
    let crashFreeUsers: Double
    let crashes: [Crash]
    let sessions: Int
    let adoption: Double
    let trend: [Int]

    var id: String { version }
}

extension ReleaseHealth {
    static func healthColor(_ value: Double) -> Color {
        switch value {
        case 0.995...: .green
        case 0.99..<0.995: .yellow
        case 0.98..<0.99: .orange
        default: .red
        }
    }

    static func percent(_ value: Double, fraction: Int = 2) -> String {
        String(format: "%.\(fraction)f%%", value * 100)
    }

    static func compact(_ value: Int) -> String {
        switch value {
        case 1_000_000...: String(format: "%.1fM", Double(value) / 1_000_000)
        case 1_000...: String(format: "%.1fK", Double(value) / 1_000)
        default: "\(value)"
        }
    }
}

extension ReleaseHealth {
    static let samples: [ReleaseHealth] = [
        ReleaseHealth(
            version: "3.2.0",
            build: "412",
            crashFreeSessions: 0.9982,
            crashFreeUsers: 0.9991,
            crashes: sampleCrashes(["NSRangeException": 8, "Fatal error": 4, "SIGSEGV": 2]),
            sessions: 48210,
            adoption: 0.62,
            trend: [3, 5, 4, 6, 4, 7, 5]
        ),
        ReleaseHealth(
            version: "3.1.4",
            build: "405",
            crashFreeSessions: 0.9967,
            crashFreeUsers: 0.9975,
            crashes: sampleCrashes(["NSRangeException": 16, "Fatal error": 9, "SIGSEGV": 6]),
            sessions: 26110,
            adoption: 0.21,
            trend: [6, 5, 7, 5, 8, 6, 9]
        ),
        ReleaseHealth(
            version: "3.1.0",
            build: "390",
            crashFreeSessions: 0.9921,
            crashFreeUsers: 0.9943,
            crashes: sampleCrashes(["NSRangeException": 30, "Fatal error": 18, "SIGSEGV": 10]),
            sessions: 12050,
            adoption: 0.10,
            trend: [9, 11, 8, 10, 12, 9, 13]
        ),
        ReleaseHealth(
            version: "3.0.2",
            build: "360",
            crashFreeSessions: 0.9890,
            crashFreeUsers: 0.9905,
            crashes: sampleCrashes(["NSRangeException": 22, "Fatal error": 12, "SIGSEGV": 8]),
            sessions: 4300,
            adoption: 0.05,
            trend: [12, 10, 14, 11, 9, 8, 7]
        ),
        ReleaseHealth(
            version: "2.9.9",
            build: "333",
            crashFreeSessions: 0.9710,
            crashFreeUsers: 0.9802,
            crashes: sampleCrashes(["NSRangeException": 35, "Fatal error": 22, "SIGSEGV": 16]),
            sessions: 1820,
            adoption: 0.02,
            trend: [20, 18, 22, 19, 17, 15, 16]
        ),
    ]

    private static func sampleCrashes(_ counts: KeyValuePairs<String, Int>) -> [Crash] {
        var crashes: [Crash] = []
        var index = 0

        for (name, count) in counts {
            for _ in 0..<count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                crashes.append(.sample(name, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return crashes
    }
}
