//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension ReleaseAdoption {
    init(releases: [ReleaseHealth]) {
        self.init(
            versions:
                releases
                .sorted { $0.adoption.value > $1.adoption.value }
                .map { release in
                    Version(
                        id: release.id,
                        share: release.adoption.value,
                        stability: release.freeSessions,
                        shipped: release.released
                    )
                }
        )
    }
}
