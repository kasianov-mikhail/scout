//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias SyncAction = @MainActor () async throws -> Void

@MainActor class SyncController {
    let container: CKContainer

    private let dispatcher: Dispatcher

    init(container: CKContainer, dispatcher: Dispatcher = QueueDispatcher()) {
        self.container = container
        self.dispatcher = dispatcher
    }

    func synchronize() async throws {
        guard try await container.accountStatus() == .available else {
            throw NotLoggedInError()
        }

        let engine = SyncEngine(database: container.publicCloudDatabase, context: persistentContainer.viewContext)
        let jobPlan = SyncJobPlan(engine: engine)

        try SyncableObject.cleanup(in: persistentContainer.viewContext)
        try await dispatcher.performEnsuringBackground {
            for job in jobPlan.jobs.shuffled() {
                try Task.checkCancellation()
                try await job()
            }
        }
    }

    struct NotLoggedInError: LocalizedError {
        let errorDescription: String? = "User is not logged in to iCloud"
    }
}
