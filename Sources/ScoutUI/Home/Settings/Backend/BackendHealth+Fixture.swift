//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension BackendHealth: Fixture {
    static var samples: [BackendHealth] {
        [
            BackendHealth(
                id: "https://api.scout.app",
                name: "Production",
                engine: .server(
                    .init(endpoint: "api.scout.app", hasAPIKey: true, isSecure: true)
                ),
                status: .reachable,
                latency: 148,
                lastChecked: Date(timeIntervalSinceNow: -12),
                pings: [140, 152, 138, 171, 149, 162, 144, 155, 148, 158, 143, 148],
                probe: {
                    try? await Task.sleep(for: .milliseconds(148))
                    return .reachable
                }
            ),
            BackendHealth(
                id: "iCloud.com.example.scout",
                name: "iCloud",
                engine: .cloudKit,
                status: .reachable,
                latency: 264,
                lastChecked: Date(timeIntervalSinceNow: -47),
                pings: [251, 244, 302, 268, 259, 281, 247, 322, 264, 255, 273, 264],
                probe: {
                    try? await Task.sleep(for: .milliseconds(264))
                    return .reachable
                }
            ),
            BackendHealth(
                id: "https://staging.scout.app",
                name: "Staging",
                engine: .server(
                    .init(endpoint: "staging.scout.app", hasAPIKey: false, isSecure: true)
                )
            ),
            BackendHealth(
                id: "http://localhost:8080",
                name: "Local",
                engine: .server(
                    .init(endpoint: "localhost:8080", hasAPIKey: false, isSecure: false)
                ),
                status: .unreachable,
                lastChecked: Date(timeIntervalSinceNow: -340),
                probe: { .unreachable }
            ),
        ]
    }
}
