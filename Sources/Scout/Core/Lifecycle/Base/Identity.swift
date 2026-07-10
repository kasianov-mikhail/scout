//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol Identity: Sendable {
    var install: UUID { get }
    var launch: UUID { get }
    var device: UUID { get }
    var session: SessionID { get }
}

final class SessionID: @unchecked Sendable {
    private let queue = DispatchQueue(label: "scout.identity.session")

    // Read directly by crash/signal handlers to capture the session ID without
    // `queue.sync`, which is async-signal-unsafe and can deadlock — a fatal
    // signal on a thread already inside the queue re-enters `sync` on itself.
    nonisolated(unsafe) private(set) var raw = UUID()

    // Rotates on every `SessionObject.trigger`. `SessionObject.trigger` reads it
    // from arbitrary Core Data background contexts, so access is serialised
    // through a dispatch queue to avoid torn reads when rotation races with
    // concurrent inserts.
    var current: UUID {
        get { queue.sync { raw } }
        set { queue.sync { raw = newValue } }
    }
}

struct LiveIdentity: Identity {
    let install: UUID
    let launch: UUID
    let device: UUID
    let session: SessionID

    init() {
        install = UserDefaults.standard.ensure("scout_install_id")
        device = KeychainStorage.standard.ensure("scout_device_id")
        launch = UUID()
        session = SessionID()
    }
}

// The process-wide identity, modelled as a single overridable slot so tests can
// substitute a fixture. Read directly only by call sites that cannot receive an
// injected value — async-signal crash/hang handlers running in non-capturing C
// callbacks, and globally bootstrapped logging/metrics infrastructure.
enum GlobalIdentity {
    nonisolated(unsafe) static var live: Identity = LiveIdentity()
}
