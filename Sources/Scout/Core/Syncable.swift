//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// Core Data models that can be synchronized as small, logical batches.
///
/// Contract:
/// - `group(in:)` returns **one** batch (or `nil` if nothing pending).
/// - Implementations are free to choose the grouping key (e.g. week/name).
/// - Keep batches small (use a seed row + its key to collect the set).
///
protocol Syncable: NSManagedObject {

    /// Returns a batch of currently-unsynced objects, or `nil` if none.
    ///
    /// Implementations should:
    /// - use one “seed” unsynced row to determine the batch key,
    /// - fetch the rest of the unsynced rows matching that key,
    /// - map them into `SyncGroup`.
    ///
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup?

    /// Whether this instance has been sent upstream.
    var isSynced: Bool { get set }
}

/// Errors for missing required fields when building a batch.
///
enum SyncableError: Error {
    case missingProperty(String)

    var localizedDescription: String {
        switch self {
        case let .missingProperty(property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}
