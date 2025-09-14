//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import UIKit

private let dispatcher = SkipDispatcher()

struct SyncDriver: @unchecked Sendable {
    let database: Database
    let context: NSManagedObjectContext

    func send() async throws {
        try await dispatcher.execute {
            let task = await UIApplication.shared.beginBackgroundTask()

            defer {
                Task {
                    await UIApplication.shared.endBackgroundTask(task)
                }
            }

            for job in jobs.shuffled() {
                try await job()
            }
        }
    }

    private typealias Job = () async throws -> Void

    private var jobs: [Job] {
        [
            { try await send(type: EventObject.self) },
            { try await send(type: SessionObject.self) },
            { try await send(type: UserActivity.self) },
            { try await send(type: IntMetricsObject.self) },
            { try await send(type: DoubleMetricsObject.self) },
        ]
    }

    @MainActor
    func send<T: Syncable>(type syncable: T.Type) async throws {
        while let batch = try syncable.group(in: context), let matrix = syncable.matrix(of: batch) {
            try await SyncCoordinator(
                database: database,
                maxRetry: 3,
                matrix: matrix
            )
            .upload()

            if let objects = batch as? [CKRepresentable] {
                try await database.modifyRecords(
                    saving: objects.map(\.toRecord),
                    deleting: []
                )
            }

            for object in batch {
                object.isSynced = true
            }

            try context.save()
        }
    }
}
