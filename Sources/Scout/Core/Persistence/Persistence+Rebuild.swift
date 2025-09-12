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
            try loadStores()
            logger.info("Core Data store wiped and recreated due to model incompatibility.")
        } catch {
            fatalError("Failed to wipe Core Data store: \(error)")
        }
    }

    func destroyStore() throws {
        viewContext.reset()

        if let store = persistentStoreCoordinator.persistentStores.first, let url = store.url {
            try persistentStoreCoordinator.remove(store)
            try persistentStoreCoordinator.destroyPersistentStore(
                at: url,
                ofType: NSSQLiteStoreType
            )
        } else if let url = persistentStoreDescriptions.first?.url {
            try persistentStoreCoordinator.destroyPersistentStore(
                at: url,
                ofType: NSSQLiteStoreType
            )
        }
    }
}
