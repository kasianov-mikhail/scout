//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(named: "Scout")

    do {
        try container.loadStore()
    } catch let error as NSError {
        fatalError("Error loading Core Data store: \(error) | \(error.userInfo)")
    }

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
        for description in persistentStoreDescriptions {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        var captured: Error?
        loadPersistentStores { _, error in
            captured = error
        }
        if let captured {
            throw captured
        }
    }
}
