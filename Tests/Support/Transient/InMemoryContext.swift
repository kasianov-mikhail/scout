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
    @MainActor
    static func inMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(named: "ScoutModel")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        container.persistentStoreDescriptions = [description]

        // Load through the production path so the view context carries the same
        // merge configuration the delivery engine depends on.
        do {
            try container.loadStore()
        } catch {
            fatalError("Failed to load store: \(error)")
        }

        return container.viewContext
    }
}
