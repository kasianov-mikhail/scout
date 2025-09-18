//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Logging

private let logger = Logger(label: "Scout.CoreData")

extension NSPersistentContainer {
    func rebuildStore() {
        do {
            try destroyStore()
            try loadStore()
            logger.info("Core Data store wiped and recreated due to model incompatibility.")
        } catch {
            fatalError("Failed to wipe Core Data store: \(error)")
        }
    }

    func destroyStore() throws {
        viewContext.reset()

        if let store = persistentStoreCoordinator.persistentStores.first, let url = store.url {
            try persistentStoreCoordinator.remove(store)
            try persistentStoreCoordinator.destroySQLite(at: url)
        } else if let url = persistentStoreDescriptions.first?.url {
            try persistentStoreCoordinator.destroySQLite(at: url)
        }
    }
}

extension NSPersistentStoreCoordinator {
    fileprivate func destroySQLite(at url: URL) throws {
        try destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
    }
}
