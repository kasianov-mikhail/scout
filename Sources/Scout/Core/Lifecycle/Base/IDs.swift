//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum IDs {
    private static let sessionQueue = DispatchQueue(label: "scout.ids.session")

    // Read directly by crash/signal handlers to capture the session ID without
    // `sessionQueue.sync`, which is async-signal-unsafe and can deadlock — a
    // fatal signal on a thread already inside the queue re-enters `sync` on
    // itself. Writes stay private so rotation still runs through `session`.
    nonisolated(unsafe) private(set) static var rawSession = UUID()

    /// Rotates on every `SessionObject.trigger`. `SessionObject.awakeFromInsert`
    /// reads it from arbitrary Core Data background contexts, so access is
    /// serialised through a dispatch queue to avoid torn reads when rotation
    /// races with concurrent inserts.
    ///
    static var session: UUID {
        get { sessionQueue.sync { rawSession } }
        set { sessionQueue.sync { rawSession = newValue } }
    }

    static let launch = UUID()

    static let install = UserDefaults.standard.ensure("scout_install_id")

    static let device = KeychainStorage.standard.ensure("scout_device_id")
}
