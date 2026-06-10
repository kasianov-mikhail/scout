//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// Marker for `SyncableObject` subclasses that know how to gather
/// themselves into sync-ready batches.
///
/// `group(in:)` returns the next pending batch (e.g. all unsynced records
/// sharing the same week), or `nil` if nothing pending.
///
protocol Syncable: SyncableObject {
    static func group(in context: NSManagedObjectContext) throws -> [Self]?
}

/// Progress of a record through the sync pipeline.
///
/// A record advances `pending → aggregated → synced`. The intermediate
/// `aggregated` state marks records whose counts are already merged into
/// the server matrix, so a retry after a partial sync failure doesn't
/// re-contribute them and double-count the matrix.
///
enum SyncState: Int16 {
    /// Not uploaded yet; the next sync cycle picks the record up.
    case pending = 0

    /// Counts are merged into the server matrix, but the cycle hasn't
    /// finished — the record is still re-sent as a raw upload (idempotent).
    case aggregated = 1

    /// Fully uploaded; eligible for cleanup once old enough.
    case synced = 2
}

@objc(SyncableObject)
class SyncableObject: IDObject {
    @NSManaged var syncStatePrimitive: Int16
    @NSManaged var syncAttempts: Int

    var syncState: SyncState {
        get {
            SyncState(rawValue: syncStatePrimitive) ?? .pending
        }
        set {
            syncStatePrimitive = newValue.rawValue
        }
    }

    static func batch<T: SyncableObject>(in context: NSManagedObjectContext, matching keyPaths: [PartialKeyPath<T>]) throws -> [T]? {
        let entityName = String(describing: T.self)

        let seedRequest = NSFetchRequest<T>(entityName: entityName)
        seedRequest.predicate = NSPredicate(format: "syncStatePrimitive != %d", SyncState.synced.rawValue)
        seedRequest.fetchLimit = 1

        guard let seed = try context.fetch(seedRequest).first else {
            return nil
        }

        var predicates = [NSPredicate(format: "syncStatePrimitive != %d", SyncState.synced.rawValue)]

        for keyPath in keyPaths {
            if let key = keyPath._kvcKeyPathString, let value = seed.value(forKey: key) as? NSObject {
                predicates.append(NSPredicate(format: "%K == %@", key, value))
            }
        }

        let batchRequest = NSFetchRequest<T>(entityName: entityName)
        batchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return try context.fetch(batchRequest)
    }
}
