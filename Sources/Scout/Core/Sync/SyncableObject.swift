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

/// Progress of a record's CloudKit matrix contribution.
///
/// A record advances `pending → aggregated → synced`. The intermediate
/// `aggregated` state marks records whose counts are already merged into
/// the CloudKit matrix, so a retry after a partial sync failure doesn't
/// re-contribute them and double-count the matrix.
///
/// Raw record fan-out across backends is tracked separately, per backend,
/// in `deliveryData`: a record only reaches `synced` once its matrix is
/// contributed *and* its raw record has been delivered to every backend
/// that takes one.
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

    /// JSON-encoded set of backend ids that have received the raw record.
    @NSManaged var deliveryData: Data?

    var syncState: SyncState {
        get {
            SyncState(rawValue: syncStatePrimitive) ?? .pending
        }
        set {
            syncStatePrimitive = newValue.rawValue
        }
    }

    /// The backends whose raw upload of this record has already succeeded.
    ///
    /// Tracked per backend so a healthy backend isn't re-written while a
    /// failing one is retried, and so a record only counts as fully synced
    /// once every backend that needs the raw record has it.
    ///
    var deliveredRaw: Set<String> {
        get {
            guard let deliveryData, let ids = try? JSONDecoder().decode([String].self, from: deliveryData) else {
                return []
            }
            return Set(ids)
        }
        set {
            deliveryData = try? JSONEncoder().encode(newValue.sorted())
        }
    }

    /// Records that `backendID` has received this record's raw upload.
    func markRawDelivered(to backendID: String) {
        deliveredRaw.insert(backendID)
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
