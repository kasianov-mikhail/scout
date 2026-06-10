//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@Suite("Model version migration")
struct ModelMigrationTests {
    /// Opens every store fixture in `Fixtures` with the current model.
    ///
    /// Each `Scout-v*.sqlite` fixture is an empty store created by a shipped
    /// model version, so `loadStore()` must migrate it in place. When adding
    /// a model version, also add a fixture for it: compile the model with
    /// `xcrun momc Sources/Scout/Scout.xcdatamodeld <out>.momd` and create a
    /// store from it with `NSPersistentStoreCoordinator.addPersistentStore`,
    /// passing `journal_mode=DELETE` so the fixture stays a single file.
    ///
    @Test("Stores created by shipped model versions open with the current model")
    func openFixtureStores() throws {
        let fixtures = Bundle.module.urls(forResourcesWithExtension: "sqlite", subdirectory: "Fixtures") ?? []
        try #require(fixtures.count > 0)

        for fixture in fixtures {
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: directory) }

            let storeURL = directory.appendingPathComponent(fixture.lastPathComponent)
            try FileManager.default.copyItem(at: fixture, to: storeURL)

            let container = NSPersistentContainer.newContainer(named: "Scout")
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
            try container.loadStore()

            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType,
                at: storeURL,
                options: nil
            )
            #expect(
                container.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata),
                "\(fixture.lastPathComponent) did not migrate to the current model"
            )
        }
    }
}
