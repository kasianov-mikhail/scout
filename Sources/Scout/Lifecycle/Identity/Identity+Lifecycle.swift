//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension Identity {
    var foregroundCommands: [any Command] {
        [
            SessionEntry.Rotation(session: session, launchID: launch),
            VisitEntry.Trigger(launchID: launch),
            MarkerEntry.Trigger(installID: install),
        ]
    }

    func enter() async throws {
        try await persistentContainer.run(foregroundCommands)
    }

    func leave() async throws {
        try await persistentContainer.run(
            SessionEntry.Complete(launchID: launch)
        )
    }
}
