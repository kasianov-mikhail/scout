//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSPersistentContainer {
    /// Loads the persistent store, migrating it in place when it was created
    /// by an older model version.
    ///
    /// The store is never reset: schema changes must ship as a new model
    /// version in `Scout.xcdatamodeld`, with a mapping model when lightweight
    /// inference can't cover the change.
    ///
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
