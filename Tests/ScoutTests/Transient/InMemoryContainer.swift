//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

final class InMemoryContainer: NSPersistentContainer, @unchecked Sendable {
    private let injectedError: Error

    init(name: String, managedObjectModel model: NSManagedObjectModel, injectedError: Error) {
        self.injectedError = injectedError
        super.init(name: name, managedObjectModel: model)

        // Provide a store description so super doesn't try to auto-create one.
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        self.persistentStoreDescriptions = [description]
    }

    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        // Call completion with the injected error to simulate a failure.
        let description = persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        block(description, injectedError)
    }
}
