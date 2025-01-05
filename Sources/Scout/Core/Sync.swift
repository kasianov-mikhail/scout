//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A private instance of `Dispatcher` used for managing and coordinating tasks.
private let dispatcher = Dispatcher()

/// Synchronizes data with the specified CloudKit container.
///
/// This function checks the account status of the CloudKit container and ensures that the user is logged in.
/// It then executes a synchronization process that uploads data to the CloudKit public database and deletes
/// the synchronized events from the local Core Data context.
///
/// - Parameter container: The CloudKit container to use for synchronization.
///
/// - Throws: An error of type `SyncError.notLoggedIn` if the user is not logged in to iCloud,
///           or any error encountered during the synchronization process.
///
public func sync(in container: CKContainer?) async throws {
    guard let container else {
        throw SyncError.containerNotFound
    }
    guard try await container.accountStatus() == .available else {
        throw SyncError.notLoggedIn
    }

    /// Because CloudKit network requests are executed sequentially, there is no point in running multiple
    /// synchronisation cycles in parallel. Instead, the initial loop rechecks for unuploaded events after each execution.
    try await dispatcher.execute {
        try await sync(
            syncables: [EventModel.self, Session.self],
            database: container.publicCloudDatabase,
            context: persistentContainer.viewContext
        )
    }
}

@MainActor func sync(
    syncables: [Syncable.Type], database: Database, context: NSManagedObjectContext
) async throws {
    while let group = try syncables.group(in: context) {
        let coordinator = SyncCoordinator(
            database: database,
            maxRetry: 3,
            group: group
        )

        try await coordinator.upload()

        for id in group.objectIDs {
            context.deleteObject(with: id)
        }
        try context.save()
    }
}

// MARK: - Errors

/// An error type that represents a synchronization error.
enum SyncError: Error {

    /// The CloudKit container was not found.
    case containerNotFound

    /// The user is not logged in to iCloud.
    case notLoggedIn

    var localizedDescription: String {
        switch self {
        case .containerNotFound:
            return
                "CloudKit container not found. Call `setup(container:)` while initializing the app."
        case .notLoggedIn:
            return "User is not logged in to iCloud"
        }
    }
}

// MARK: - Core Data

extension NSManagedObjectContext {

    /// Deletes the object with the specified object ID.
    fileprivate func deleteObject(with objectID: NSManagedObjectID) {
        delete(object(with: objectID))
    }
}
