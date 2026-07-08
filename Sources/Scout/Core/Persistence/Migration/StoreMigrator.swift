//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

enum StoreMigratorError: Error {
    case missingModel
}

/// Migrates a store sitting at an arbitrary older model version up to the current one.
///
/// Runs in two stages so both hops stay lightweight enough to run on every OS version
/// Scout supports (no `NSStagedMigrationManager`, iOS 17+ only):
///
/// 1. Whatever version the store is at → Scout 13, via Core Data's inferred
///    mapping — every prior model bump has been mutually lightweight-compatible,
///    so this covers stores that are many versions behind in a single hop.
/// 2. Scout 13 → the current model, via `RelationshipBackfillMigrationPolicy`,
///    since turning the old `deviceID`/`installID`/`launchID`/`sessionID`
///    scalars into relationships isn't something inference can do.
///
/// A store already on the current model, or with no file on disk yet (first
/// launch, or an in-memory store used by tests), is left untouched.
///
struct StoreMigrator {
    let url: URL
    let type: String
    let bundle: Bundle

    func migrateIfNeeded(currentModel: NSManagedObjectModel) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: url, options: nil)

        guard !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            return
        }
        guard NSManagedObjectModel.mergedModel(from: [bundle], forStoreMetadata: metadata) != nil else {
            return
        }
        guard let momdURL = bundle.url(forResource: "Scout", withExtension: "momd") else {
            return
        }
        guard let scout13Model = NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("Scout 13.mom")) else {
            throw StoreMigratorError.missingModel
        }

        var workingURL = url

        if !scout13Model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
            workingURL = try migrate(storeAt: workingURL, to: scout13Model) { source, destination in
                try NSMappingModel.inferredMappingModel(forSourceModel: source, destinationModel: destination)
            }
        }

        workingURL = try migrate(storeAt: workingURL, to: currentModel, mapping: backfillMapping)

        try replace(storeAt: url, withStoreAt: workingURL, model: currentModel)
    }

    private func backfillMapping(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) throws -> NSMappingModel {
        let mapping = try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        let policyClassName = NSStringFromClass(RelationshipBackfillMigrationPolicy.self)

        for entityMapping in mapping.entityMappings {
            entityMapping.entityMigrationPolicyClassName = policyClassName
        }

        return mapping
    }

    private func migrate(
        storeAt sourceURL: URL,
        to destinationModel: NSManagedObjectModel,
        mapping mappingBuilder: (NSManagedObjectModel, NSManagedObjectModel) throws -> NSMappingModel
    ) throws -> URL {
        let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: sourceURL, options: nil)

        guard let sourceModel = NSManagedObjectModel.mergedModel(from: [bundle], forStoreMetadata: sourceMetadata) else {
            throw StoreMigratorError.missingModel
        }

        let mapping = try mappingBuilder(sourceModel, destinationModel)
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).sqlite")

        try manager.migrateStore(
            from: sourceURL,
            sourceType: type,
            options: nil,
            with: mapping,
            toDestinationURL: destinationURL,
            destinationType: type,
            destinationOptions: nil
        )

        return destinationURL
    }

    private func replace(storeAt url: URL, withStoreAt migratedURL: URL, model: NSManagedObjectModel) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        try coordinator.replacePersistentStore(
            at: url,
            destinationOptions: nil,
            withPersistentStoreFrom: migratedURL,
            sourceOptions: nil,
            ofType: type
        )
        try coordinator.destroyPersistentStore(at: migratedURL, ofType: type, options: nil)
    }
}
