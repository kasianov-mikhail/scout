//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

final class TemporaryStore {
    /// Every store keeps its own directory for the whole process.
    ///
    /// Removing a directory whose store is still open leaves SQLite with a
    /// process-wide "vnode unlinked while in use" entry, and the next store
    /// that inherits it fails to open. The iOS 17 leg also kept losing a live
    /// store file mid-test, so a run no longer deletes what it created: the
    /// next run reaps the leftovers before it opens anything.
    ///
    let directory = URL.applicationSupportDirectory.appending(path: "ScoutTests").appending(path: UUID().uuidString)

    private var containers: [NSPersistentContainer] = []

    var url: URL {
        directory.appendingPathComponent("ScoutModel.sqlite")
    }

    init() throws {
        _ = Self.reapStaleDirectories
        try makeDirectory()
    }

    func seed(model: NSManagedObjectModel, body: @Sendable (NSManagedObjectContext) throws -> Void) throws {
        let seedURL = directory.appendingPathComponent("Seed.sqlite")

        try autoreleasepool {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"] as NSDictionary]
            let store = try coordinator.addPersistentStore(type: .sqlite, at: seedURL, options: options)
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator

            try context.performAndWait {
                try body(context)
                try context.save()
            }
            try coordinator.remove(store)
        }

        try FileManager.default.copyItem(at: seedURL, to: url)
    }

    func container() throws -> NSPersistentContainer {
        try makeDirectory()

        let container = NSPersistentContainer(named: "ScoutModel")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        try container.loadStore()

        guard container.isStoreLoaded else {
            throw UnopenedStoreError(url: url)
        }

        containers.append(container)
        return container
    }

    /// Detaches the stores so no file stays open.
    ///
    /// The directory stays on disk: see `directory`.
    ///
    func tearDown() {
        for container in containers {
            let coordinator = container.persistentStoreCoordinator
            for store in coordinator.persistentStores {
                try? coordinator.remove(store)
            }
        }
        containers.removeAll()
    }

    private func makeDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// Deletes the directories of earlier runs once per process, before this
    /// process opens a store, so no live file is unlinked.
    ///
    private static let reapStaleDirectories: Void = {
        let root = URL.applicationSupportDirectory.appending(path: "ScoutTests")
        let keys: Set<URLResourceKey> = [.contentModificationDateKey]
        guard
            let directories = try? FileManager.default.contentsOfDirectory(
                at: root,
                includingPropertiesForKeys: Array(keys)
            )
        else {
            return
        }

        let cutoff = Date.now.addingTimeInterval(-6 * 3600)
        for directory in directories {
            let date = (try? directory.resourceValues(forKeys: keys))?.contentModificationDate
            if let date, date < cutoff {
                try? FileManager.default.removeItem(at: directory)
            }
        }
    }()
}

struct UnopenedStoreError: LocalizedError {
    let url: URL

    var errorDescription: String? {
        "The store at \(url.path) did not open"
    }
}
