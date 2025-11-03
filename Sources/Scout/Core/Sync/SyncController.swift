//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor class SyncController {
    static let shared = SyncController()

    var container: CKContainer?

    private let dispatcher: Dispatcher

    private init(dispatcher: Dispatcher = QueueDispatcher()) {
        self.dispatcher = dispatcher
    }

    func synchronize() async throws {
        guard let container else {
            throw Error.containerNotFound
        }
        guard try await container.accountStatus() == .available else {
            throw Error.notLoggedIn
        }

        let engine = SyncEngine(
            database: container.publicCloudDatabase,
            context: persistentContainer.viewContext
        )
        let jobPlan = SyncJobPlan(engine: engine)

        try await dispatcher.performEnsuringBackground {
            for job in jobPlan.jobs.shuffled() {
                try await job()
            }
        }
    }

    enum Error: LocalizedError {
        case containerNotFound
        case notLoggedIn

        var errorDescription: String? {
            switch self {
            case .containerNotFound:
                "CloudKit container not found. Call `setup(container:)` while initializing the app."
            case .notLoggedIn:
                "User is not logged in to iCloud"
            }
        }
    }
}
