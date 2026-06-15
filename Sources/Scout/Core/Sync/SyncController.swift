//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

typealias SyncAction = @MainActor () async throws -> Void

@MainActor class SyncController {
    let backends: [ResolvedBackend]

    private let dispatcher: Dispatcher

    init(backends: [ResolvedBackend], dispatcher: Dispatcher = QueueDispatcher()) {
        self.backends = backends
        self.dispatcher = dispatcher
    }

    func synchronize() async throws {
        try SyncableObject.cleanup(in: persistentContainer.viewContext)

        // Sync advances a record's state once for all backends, so every
        // backend must be reachable before any upload starts — otherwise a
        // record could be marked synced without reaching the missing one.
        for backend in backends {
            try await backend.checkAvailability()
        }

        let engine = SyncEngine(backends: backends, context: persistentContainer.viewContext)
        let jobPlan = SyncJobPlan(engine: engine)

        try await dispatcher.performEnsuringBackground {
            await withTaskGroup(of: Void.self) { group in
                for job in jobPlan.jobs.shuffled() {
                    group.addTask {
                        try? await job()
                    }
                }
            }
            try Task.checkCancellation()
        }
    }

    struct NotLoggedInError: LocalizedError {
        let errorDescription: String? = "User is not logged in to iCloud"
    }
}
