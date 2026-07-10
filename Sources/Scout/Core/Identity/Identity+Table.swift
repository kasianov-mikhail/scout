//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension Identity {
    var table: ActionTable {
        ActionTable(actions: [
            AppLifecycle.willEnterForeground: enter,
            AppLifecycle.didEnterBackground: leave,
        ])
    }

    func enter() async throws {
        try await persistentContainer.run(
            SessionObject.Trigger(session: session, launchID: launch),
            UserActivityObject.Trigger(session: session),
            VersionMarker.Trigger(installID: install)
        )
    }

    func leave() async throws {
        try await persistentContainer.run(
            SessionObject.Complete(launchID: launch),
            UserActivityObject.Trigger(session: session)
        )
    }
}
