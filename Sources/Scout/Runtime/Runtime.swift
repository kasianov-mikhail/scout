//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Scout's shared machinery: the identity behind every record, the sync loop that ships
/// them, and the crash and hang handlers.
///
/// Create one during app launch and hand it to ``ScoutLogHandler`` and
/// ``ScoutMetricsFactory``:
///
/// ```swift
/// let scout = Runtime(backends: [.cloudKit(container)])
///
/// LoggingSystem.bootstrap {
///     ScoutLogHandler(label: $0, runtime: scout)
/// }
/// MetricsSystem.bootstrap(
///     ScoutMetricsFactory(runtime: scout)
/// )
/// ```
///
/// One runtime per app: a second one would install the crash handlers twice and open a
/// second session against the same store.
///
public struct Runtime: Sendable {
    let backends: [Backend]
    let identity: Identity
    let sync: Synchronize

    var session: Protected<UUID> {
        identity.session
    }

    var isEnabled: Bool {
        backends.count > 0
    }
}

extension Runtime {
    /// Creates the runtime and starts it in the background.
    ///
    /// Construction is synchronous, so the handlers built from it work right away; the
    /// lifecycle records, the crash and hang handlers, and the first sync land shortly
    /// after. A failure to start is printed, not thrown — a logging framework that
    /// aborts app launch would be worse than one that misses a session.
    ///
    /// - Parameter backends: The backends to sync to, in any combination of CloudKit
    ///   containers and Scout servers. An empty list turns Scout off: nothing is
    ///   recorded or synced.
    ///
    public init(backends: [Backend]) {
        let identity = Identity(
            install: UserDefaults.standard.ensure("scout_install_id"),
            launch: UUID(),
            device: KeychainStorage.standard.ensure("scout_device_id"),
            session: Protected(UUID())
        )

        let dispatcher = Coalescer()

        self.init(
            backends: backends,
            identity: identity,
            sync: { try await synchronize(backends: backends, dispatcher: dispatcher) }
        )

        guard isEnabled else {
            return
        }

        let runtime = self

        Task { @MainActor in
            do {
                try await runtime.start()
            } catch {
                print("Failed to start Scout: \(error)")
            }
        }
    }

    @MainActor
    func start() async throws {
        for backend in backends {
            backend.onSetup()
        }

        try await identity.bootstrap()

        identity.table.startListening(completion: sync)

        Task {
            do {
                try await sync()
            } catch {
                print("Failed to run the first sync: \(error)")
            }
        }
    }
}
