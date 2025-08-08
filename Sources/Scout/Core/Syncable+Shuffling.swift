//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension [Syncable.Type] {

    /// Returns the first non-`nil` `SyncGroup` produced by any contained `Syncable` type.
    ///
    /// Strategy:
    /// - Shuffles the array to avoid favoring the same type repeatedly.
    /// - Asks each type to build a batch via `group(in:)`.
    ///
    /// - Parameter context: An `NSManagedObjectContext` to query.
    /// - Returns: The first available `SyncGroup`, or `nil` if nothing is pending across all types.
    ///
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
