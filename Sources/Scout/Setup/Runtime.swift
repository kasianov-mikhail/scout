//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Runtime: Sendable {
    let session: Protected<UUID>
    let sync: Synchronize
}

extension Runtime {
    @MainActor
    init(backends: [Backend]) async throws {
        for backend in backends {
            backend.onSetup()
        }

        let session = Protected(UUID())

        let identity = Identity(
            install: UserDefaults.standard.ensure("scout_install_id"),
            launch: UUID(),
            device: KeychainStorage.standard.ensure("scout_device_id"),
            session: session
        )

        try await identity.bootstrap()

        let dispatcher = Coalescer()

        @Sendable func sync() async throws {
            try await synchronize(backends: backends, dispatcher: dispatcher)
        }

        identity.table.startListening(completion: sync)

        self.init(session: session, sync: sync)

        Task {
            do {
                try await sync()
            } catch {
                print("Failed to run the first sync: \(error)")
            }
        }
    }
}
