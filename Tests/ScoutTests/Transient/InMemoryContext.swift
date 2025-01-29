//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

/// Creates and returns an in-memory `NSManagedObjectContext` for testing purposes.
/// 
/// This method sets up an `NSPersistentContainer` with an in-memory store type, which is useful for unit tests
/// where you do not want to persist data to disk. The in-memory store type allows for fast and isolated tests.
///
/// - Returns: An `NSManagedObjectContext` configured to use an in-memory store.
/// 
/// - Note: If the persistent store fails to load, this method will cause a fatal error.
///
extension NSManagedObjectContext {
    static func inMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer.newContainer(named: "Scout")

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
