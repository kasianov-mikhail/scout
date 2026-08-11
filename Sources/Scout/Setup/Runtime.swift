//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Runtime: Sendable {
    let identity: Identity
    let sync: Synchronize

    var session: Protected<UUID> {
        identity.session
    }
}

extension Runtime {
    @MainActor
    init(backends: [Backend]) {
        for backend in backends {
            backend.onSetup()
        }

        let identity = Identity(
            install: UserDefaults.standard.ensure("scout_install_id"),
            launch: UUID(),
            device: KeychainStorage.standard.ensure("scout_device_id"),
            session: Protected(UUID())
        )

        let dispatcher = Coalescer()

        self.init(
            identity: identity,
            sync: { try await synchronize(backends: backends, dispatcher: dispatcher) }
        )
    }

    @MainActor
    func start() async throws {
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
