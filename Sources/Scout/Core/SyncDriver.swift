//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import UIKit

private let dispatcher = Dispatcher()

struct SyncDriver: @unchecked Sendable {
    let database: Database
    let context: NSManagedObjectContext

    func execute() async throws {
        try await dispatcher.execute {
            let task = await UIApplication.shared.beginBackgroundTask()

            defer {
                Task {
                    await UIApplication.shared.endBackgroundTask(task)
                }
            }

            let jobs = [
                { try await sync(EventObject.self) },
                { try await sync(SessionObject.self) },
                { try await sync(UserActivity.self) },
                { try await sync(MetricsObject.self) },
            ]

            for job in jobs.shuffled() {
                try await job()
            }
        }
    }

    @MainActor func sync<T: Syncable>(_ syncable: T.Type, ) async throws {
        while let group = try syncable.group(in: context) {
            let coordinator = SyncCoordinator(
                database: database,
                maxRetry: 3,
                group: group
            )

            try await coordinator.upload()

            if let objects = group.objects as? [CKRepresentable] {
                try await database.modifyRecords(
                    saving: objects.map(\.toRecord),
                    deleting: []
                )
            }

            for object in group.objects {
                object.isSynced = true
            }

            try context.save()
        }
    }
}
