//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

// Lightweight migration fails outright when existing rows violate a uniqueness
// constraint the destination model introduces, so stores written before the
// constraints existed must be deduplicated with their source model before
// `loadPersistentStores` runs.
struct MigrationDedupe {
    static let uniqueKeys: [(entity: String, key: String)] = [
        ("DeviceEntry", "deviceID"),
        ("InstallEntry", "installID"),
        ("LaunchEntry", "launchID"),
        ("SessionEntry", "sessionID"),
    ]

    let model: NSManagedObjectModel
    var bundles: [Bundle] = [.module]

    func prepare(_ description: NSPersistentStoreDescription) throws {
        guard description.type == NSSQLiteStoreType else { return }
        guard let url = description.url else { return }
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: url)
        guard !model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else { return }
        guard let source = NSManagedObjectModel.mergedModel(from: bundles, forStoreMetadata: metadata) else {
            return
        }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: source)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: url)
        defer { try? coordinator.remove(store) }

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let keys = Self.uniqueKeys.filter { source.entitiesByName[$0.entity] != nil }

        try context.performAndWait {
            for (entity, key) in keys {
                try Self.dedupe(entityName: entity, key: key, in: context)
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }

    private static func dedupe(entityName: String, key: String, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: DateEntry.datePrimitiveKey, ascending: true)]

        var survivors: [UUID: NSManagedObject] = [:]
        for row in try context.fetch(request) {
            guard let id = row.value(forKey: key) as? UUID else { continue }

            if let survivor = survivors[id] {
                merge(row, into: survivor, in: context)
            } else {
                survivors[id] = row
            }
        }
    }

    private static func merge(_ duplicate: NSManagedObject, into survivor: NSManagedObject, in context: NSManagedObjectContext) {
        for name in survivor.entity.attributesByName.keys where survivor.value(forKey: name) == nil {
            if let value = duplicate.value(forKey: name) {
                survivor.setValue(value, forKey: name)
            }
        }

        let relationships = survivor.entity.relationshipsByName
        for (name, relationship) in relationships where relationship.deleteRule != .cascadeDeleteRule {
            if relationship.isToMany {
                let children = survivor.mutableSetValue(forKey: name)
                for child in duplicate.mutableSetValue(forKey: name).allObjects {
                    children.add(child)
                }
            } else if survivor.value(forKey: name) == nil, let value = duplicate.value(forKey: name) {
                survivor.setValue(value, forKey: name)
            }
        }

        // The duplicate may have delivered last, leaving its bare version on
        // the server, so the merged survivor re-sends regardless of whether
        // the merge changed it locally.
        if let syncable = survivor as? SyncableEntry {
            syncable.requeue()
        }

        context.delete(duplicate)
    }
}
