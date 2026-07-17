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
    // Loading ScoutModel.momd more than once registers a duplicate
    // NSEntityDescription per NSManagedObject subclass, and the resulting
    // ambiguous class→entity resolution races under parallel test runs —
    // intermittently escalating a constraint-conflict save into a fatal
    // "Unable to recover from optimistic locking failure". Every container
    // must share this single instance.
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
        // DeliveryEntry rows at once) from being rejected over a single duplicate.
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}
