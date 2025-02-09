//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

/// A structure representing a synchronization group.
///
/// `SyncGroup` is used to group together Core Data objects and CloudKit records
/// for the purpose of synchronizing data between a local Core Data context and a remote CloudKit database.
///
struct SyncGroup: MatrixGroup, @unchecked Sendable {

    /// The name of the synchronization group.
    let name: String

    /// The date of the synchronization group.
    let date: Date

    /// An array of objects that are part of the synchronization group.
    let objects: [Syncable]

    /// A dictionary mapping field names to their corresponding count values.
    let fields: [String: Int]
}

// MARK: - CustomStringConvertible

extension SyncGroup: CustomStringConvertible {
    var description: String {
        "SyncGroup(name: \(name), date: \(date), objects: \(objects.count), fields: \(fields))"
    }
}
