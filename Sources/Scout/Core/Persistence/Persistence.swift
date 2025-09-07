//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

private let incompatibleCodes = [
    NSPersistentStoreIncompatibleVersionHashError,
    NSMigrationError,
    NSMigrationMissingSourceModelError,
]

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer.newContainer(named: "Scout")

    do {
        try container.loadPersistentStores()
    } catch let error as NSError {
        if error.domain == NSCocoaErrorDomain && incompatibleCodes.contains(error.code) {
            container.rebuildStore()
        } else {
            fatalError("Error loading Core Data store: \(error) | \(error.userInfo)")
        }
    }

    return container
}()

extension NSPersistentContainer {
    static func newContainer(named name: String) -> NSPersistentContainer {
        guard let modelURL = Bundle.module.url(forResource: name, withExtension: "momd") else {
            fatalError("Failed to find data model")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }

        return NSPersistentContainer(name: name, managedObjectModel: model)
    }
}
