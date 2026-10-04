//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Identity {
    struct Snapshot: Sendable {
        let install: UUID
        let launch: UUID
        let device: UUID
        let session: UUID
    }

    var snapshot: Snapshot {
        Snapshot(install: install, launch: launch, device: device, session: session.current)
    }
}
