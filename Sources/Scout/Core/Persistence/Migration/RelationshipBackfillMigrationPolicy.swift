//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData

/// Backfills the `device`/`install`/`launch`/`session` relationships introduced in Scout 14.
///
/// Looks up the hub row with a matching new local primary key from the raw UUID scalars
/// (`deviceID`/`installID`/`launchID`/`sessionID`) every entity carried before. Runs as
/// the second migration pass (`createRelationships`), which Core Data guarantees fires
/// only after every entity's destination instances already exist, so the hub lookups
/// below always find their target regardless of entity processing order.
///
@objc(RelationshipBackfillMigrationPolicy)
final class RelationshipBackfillMigrationPolicy: NSEntityMigrationPolicy {
    // `sourceKey` is the scalar attribute Scout 13 carried (inherited from IDObject/
    // TrackedObject); `destinationKey` is the hub's own local primary key in Scout 14 —
    // these differ for session, since SessionObject's own PK was renamed to `id`.
    private static let hubs: [(relationship: String, entityName: String, sourceKey: String, destinationKey: String)] = [
        ("device", "DeviceObject", "deviceID", "deviceID"),
        ("install", "InstallObject", "installID", "installID"),
        ("launch", "LaunchObject", "launchID", "launchID"),
        ("session", "SessionObject", "sessionID", "id"),
    ]

    override func createRelationships(
        forDestination dInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)

        guard let sInstance = manager.sourceInstances(forEntityMappingName: mapping.name, destinationInstances: [dInstance]).first else {
            return
        }

        for hub in Self.hubs {
            guard dInstance.entity.relationshipsByName[hub.relationship] != nil,
                sInstance.entity.attributesByName[hub.sourceKey] != nil,
                let id = sInstance.value(forKey: hub.sourceKey) as? UUID
            else {
                continue
            }

            dInstance.setValue(
                try findHub(entityName: hub.entityName, key: hub.destinationKey, id: id, in: manager.destinationContext),
                forKey: hub.relationship
            )
        }
    }

    private func findHub(entityName: String, key: String, id: UUID, in context: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "%K == %@", key, id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
