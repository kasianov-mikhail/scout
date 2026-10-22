//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

struct RecordCacheStorage: @unchecked Sendable {
    private let storeName = "RecordCache.store"
    private let storeSuffixes = ["", "-shm", "-wal"]

    let directory: URL
    let manager: FileManager

    init(directory: URL = URL.applicationSupportDirectory.appending(path: "Scout", directoryHint: .isDirectory), manager: FileManager = .default) {
        self.directory = directory
        self.manager = manager
    }

    private var storeURL: URL {
        directory.appending(path: storeName)
    }

    func open() -> NSManagedObjectContext? {
        do {
            try prepare()

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: Self.model)
            _ = try coordinator.addPersistentStore(type: .sqlite, configuration: nil, at: storeURL)

            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            print("Failed to open the record cache store, so backends stay uncached until the next launch: \(error)")
            return nil
        }
    }

    func destroy(context: NSManagedObjectContext?) {
        if let coordinator = context?.persistentStoreCoordinator {
            do {
                for store in coordinator.persistentStores {
                    try coordinator.remove(store)
                }
            } catch {
                print("Failed to close the record cache store: \(error)")
            }
        }
        destroyStore()
    }

    private func prepare() throws {
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        sweepRetired()

        guard manager.fileExists(atPath: storeURL.path) else {
            return
        }
        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: storeURL)
            if Self.model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                return
            }
        } catch {
            print("Failed to read the record cache store, so it is recreated: \(error)")
        }
        destroyStore()
    }

    private func destroyStore() {
        for suffix in storeSuffixes {
            remove(path: storeURL.path + suffix)
        }
    }

    private func sweepRetired() {
        do {
            let names = try manager.contentsOfDirectory(atPath: directory.path)

            for name in names where name.hasPrefix("RecordCache") && !name.hasPrefix(storeName) {
                remove(path: directory.appending(path: name).path)
            }
        } catch {
            print("Failed to list the record cache directory: \(error)")
        }
    }

    private func remove(path: String) {
        guard manager.fileExists(atPath: path) else {
            return
        }

        do {
            try manager.removeItem(atPath: path)
        } catch {
            print("Failed to remove \(path): \(error)")
        }
    }
}
