//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

extension NSManagedObjectContext {
    // Returns the container's main-queue viewContext, so callers must be
    // @MainActor-isolated — the annotation makes the compiler enforce it.
    @MainActor
    static func inMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(named: "ScoutModel")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load store: \(error)")
            }
        }

        return container.viewContext
    }
}
