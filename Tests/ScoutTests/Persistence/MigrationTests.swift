//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Support
import Testing

@testable import Scout

@Suite("ScoutModel migrations")
struct MigrationTests {
    @Test("Every historical model version migrates to the current model")
    func historicalVersionsMigrate() throws {
        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let current = NSManagedObjectModel.scout

        let versions = try FileManager.default
            .contentsOfDirectory(at: momdURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "mom" }

        // A broken resource lookup would make the loop below pass vacuously;
        // the model ships at least three versions, so fewer means enumeration
        // silently failed.
        try #require(versions.count >= 3)

        for versionURL in versions {
            let old = try #require(NSManagedObjectModel(contentsOf: versionURL))
            guard old.entityVersionHashesByName != current.entityVersionHashesByName else { continue }

            let storeURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("sqlite")

            try SerializedStore.connect {
                let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: old)
                let oldStore = try oldCoordinator.addPersistentStore(type: .sqlite, at: storeURL)
                try oldCoordinator.remove(oldStore)

                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: current)
                let options: [String: Any] = [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true,
                ]

                do {
                    let store = try coordinator.addPersistentStore(
                        ofType: NSSQLiteStoreType,
                        configurationName: nil,
                        at: storeURL,
                        options: options
                    )
                    let metadata = coordinator.metadata(for: store)
                    #expect(current.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata))
                } catch {
                    Issue.record("Store created by \(versionURL.lastPathComponent) failed to migrate: \(error)")
                }

                try coordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType)
            }
        }
    }
}
