//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Backend: Fixture {
    static var samples: [Backend] {
        [
            Backend(
                id: "https://api.scout.app",
                database: EmptyDatabase(),
                displayName: "Production",
                engine: .cloudKit,
                probeStatus: { .reachable },
                cache: CacheSample()
            ),
            Backend(
                id: "https://staging.scout.app",
                database: EmptyDatabase(),
                displayName: "Staging",
                engine: .cloudKit
            ),
            Backend(
                id: "http://localhost:8080",
                database: EmptyDatabase(),
                displayName: "Local",
                engine: .cloudKit,
                probeStatus: { .unreachable },
                verifyAccess: { throw URLError(.notConnectedToInternet) }
            ),
        ]
    }
}
