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

    return container
}()

extension NSManagedObjectModel {
    nonisolated(unsafe) static let scout: NSManagedObjectModel = {
        guard let modelURL = Bundle.module.url(forResource: "ScoutModel", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        return model
    }()
}

extension NSPersistentContainer {
    convenience init(named name: String) {
        self.init(name: name, managedObjectModel: .scout)
    }
}

extension NSPersistentContainer {
    func loadStore() throws {
        let dedupe = MigrationDedupe(model: managedObjectModel)
        for description in persistentStoreDescriptions {
            try dedupe.prepare(description)
        }

        var captured: Error?
        loadPersistentStores { _, error in
            captured = error
        }
        if let captured {
            throw captured
        }

        viewContext.mergePolicy = NSMergePolicy.scout

        // Delivery runs on the view context while every record is written on a
        // background one, so without merging those saves the sender compares
        // stale snapshots: a record filled in mid-send counts as delivered and
        // a requeue from a background context is never seen again.
        viewContext.automaticallyMergesChangesFromParent = true
    }
}
