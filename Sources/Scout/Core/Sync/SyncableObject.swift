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

/// Whether a record still needs syncing.
///
/// `pending` until every backend has everything it needs — which steps each
/// backend has completed lives per backend in `delivery` — then `synced`.
///
enum SyncState: Int16 {
    /// Not yet fully delivered; the next sync cycle picks the record up.
    case pending = 0

    /// Legacy. Written by builds before per-backend `delivery` tracking,
    /// where it meant the CloudKit matrix had been contributed. New code
    /// never writes it; `SyncEngine` migrates such records on the next cycle.
    case aggregated = 1

    /// Delivered to every backend; eligible for cleanup once old enough.
    case synced = 2
}

/// Which steps of the sync pipeline a record has completed on one backend.
///
/// Raw uploads are idempotent upserts, so `.raw` only spares a healthy
/// backend a redundant re-write. Matrix contributions are additive, so
/// `.matrix` is what keeps a CloudKit matrix from double-counting on retry.
///
struct BackendProgress: OptionSet, Sendable {
    let rawValue: Int

    static let raw = BackendProgress(rawValue: 1 << 0)
    static let matrix = BackendProgress(rawValue: 1 << 1)
}

@objc(SyncableObject)
class SyncableObject: IDObject {
    @NSManaged var syncStatePrimitive: Int16
    @NSManaged var syncAttempts: Int

    /// JSON-encoded per-backend sync progress (`[backendID: rawValue]`).
    @NSManaged var deliveryData: Data?

    var syncState: SyncState {
        get {
            SyncState(rawValue: syncStatePrimitive) ?? .pending
        }
        set {
            syncStatePrimitive = newValue.rawValue
        }
    }

    /// How far this record has progressed on each backend, keyed by
    /// `ResolvedBackend.id`.
    ///
    /// Tracked per backend so a healthy backend isn't re-written or re-counted
    /// while a failing one is retried, and so a record only reaches `synced`
    /// once every backend has everything it needs.
    ///
    var delivery: [String: BackendProgress] {
        get {
            guard let deliveryData, let stored = try? JSONDecoder().decode([String: Int].self, from: deliveryData) else {
                return [:]
            }
            return stored.mapValues(BackendProgress.init(rawValue:))
        }
        set {
            deliveryData = try? JSONEncoder().encode(newValue.mapValues(\.rawValue))
        }
    }

    /// The steps `backendID` has completed for this record.
    func progress(for backendID: String) -> BackendProgress {
        delivery[backendID] ?? []
    }

    /// Records that `steps` have completed for `backendID`.
    func mark(_ steps: BackendProgress, for backendID: String) {
        var map = delivery
        map[backendID, default: []].formUnion(steps)
        delivery = map
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
