//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(named: "ScoutModel")

    do {
        try container.loadStore()
    } catch let error as NSError {
        fatalError("Error loading Core Data store: \(error) | \(error.userInfo)")
    }

    container.removeLegacyStore()

    return container
}()

extension NSPersistentContainer {
    convenience init(named name: String) {
        guard let modelURL = Bundle.module.url(forResource: name, withExtension: "momd") else {
            fatalError("Failed to find data model")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        self.init(name: name, managedObjectModel: model)
    }
}

extension NSPersistentContainer {
    func loadStore() throws {
        var captured: Error?
        loadPersistentStores { _, error in
            captured = error
        }
        if let captured {
            throw captured
        }

        // With the default NSErrorMergePolicy a uniqueness-constraint collision
        // fails the whole save() and leaves the offending insert pending, so on
        // the long-lived viewContext every later save() throws too. Merging by
        // property dedupes the colliding row instead — the reason the
        // constraints exist — and keeps a batched save (e.g. plan inserting many
        // SyncDelivery rows at once) from being rejected over a single duplicate.
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // The earlier schema shipped a "Scout.sqlite" store this model can't open,
    // and it is never migrated, so the old file is orphaned — remove it (best
    // effort) to reclaim its disk space rather than leave it behind forever.
    func removeLegacyStore() {
        let directory = NSPersistentContainer.defaultDirectoryURL()
        for suffix in ["", "-wal", "-shm"] {
            let url = directory.appendingPathComponent("Scout.sqlite\(suffix)")
            try? FileManager.default.removeItem(at: url)
        }
    }
}
