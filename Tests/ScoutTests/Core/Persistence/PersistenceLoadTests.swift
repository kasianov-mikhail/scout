//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@Suite("NSPersistentContainer.loadStore()")
struct PersistenceLoadTests {
    let model = NSManagedObjectModel.stub()

    @Test("loadStores succeeds with an in-memory store")
    func loadStoresSucceeds() throws {
        let container = NSPersistentContainer(name: "TestModel", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        // This should not throw
        try container.loadStore()
    }

    @Test("loadStores throws when loadPersistentStores reports an error")
    func loadStoresThrowsInjectedError() throws {
        let expectedError = NSError(domain: "TestError", code: 42)

        let container = InMemoryContainer(
            name: "TestModel",
            managedObjectModel: model,
            injectedError: expectedError
        )

        do {
            try container.loadStore()
            Issue.record("Expected loadStore() to throw, but it did not.")
        } catch let error as NSError {
            #expect(error.domain == expectedError.domain)
            #expect(error.code == expectedError.code)
        }
    }
}
