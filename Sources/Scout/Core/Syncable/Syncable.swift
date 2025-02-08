//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A protocol for types that can be synchronized. Types conforming to `Syncable` can be grouped
/// by their properties and counted. This is useful for synchronizing data between a local
/// Core Data context and a remote CloudKit database.
///
protocol Syncable {

    /// Groups the objects of the conforming type by their properties.
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup?
}

// MARK: - Random grouping

extension [Syncable.Type] {

    /// Groups the array of `Syncable` types by their properties.
    func group(in context: NSManagedObjectContext) throws -> SyncGroup? {

        // Shuffle the array to avoid grouping the same types in the same order every time.
        for syncable in shuffled() {
            if let group = try syncable.group(in: context) {
                return group
            }
        }

        return nil
    }
}

// MARK: - Error

enum SyncableError: Error {
    case missingProperty(String)

    var localizedDescription: String {
        switch self {
        case let .missingProperty(property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}
