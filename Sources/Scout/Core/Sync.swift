//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import UIKit

/// Synchronizes data with the specified CloudKit container.
///
/// This function checks the account status of the CloudKit container and ensures that the user is logged in.
/// It then executes a synchronization process that uploads data to the CloudKit public database and
/// set the `isSynced` flag on the synchronized objects.
///
/// - Parameter container: The CloudKit container to use for synchronization.
///
/// - Throws: A `SyncError` if the container is not found or the user is not logged in.
///
public func sync(in container: CKContainer?) async throws {
    guard let container else {
        throw SyncError.containerNotFound
    }
    guard try await container.accountStatus() == .available else {
        throw SyncError.notLoggedIn
    }

    try await sync(in: container)
}

// MARK: - Dispatching

/// A private instance of `Dispatcher` used for managing and coordinating tasks.
private let dispatcher = Dispatcher()

/// Because CloudKit network requests are executed sequentially, there is no point in running
/// multiple synchronisation cycles in parallel. Instead, the initial loop rechecks for unuploaded
/// events after each execution. This way, the synchronisation process is more efficient
/// and less error-prone.
///
private func sync(in container: CKContainer) async throws {
    try await dispatcher.execute {
        let task = await UIApplication.shared.beginBackgroundTask()

        defer {
            Task {
                await UIApplication.shared.endBackgroundTask(task)
            }
        }

        try await sync(
            syncables: [
                EventObject.self,
                SessionObject.self,
                UserActivity.self,
                MetricsObject.self,
            ],
            database: container.publicCloudDatabase,
            context: persistentContainer.viewContext
        )
    }
}

// MARK: - Synchronization

@MainActor func sync(
    syncables: [Syncable.Type],
    database: Database,
    context: NSManagedObjectContext
) async throws {
    while let group = try syncables.group(in: context) {
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
