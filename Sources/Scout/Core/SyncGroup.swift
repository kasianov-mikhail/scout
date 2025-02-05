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
/// `SyncGroup` is used to group together Core Data object IDs and CloudKit records
///
struct SyncGroup: Equatable, @unchecked Sendable {

    /// The name of the synchronization group.
    let name: String

    /// The date of the synchronization group
    let date: Date

    /// An array of Core Data object IDs associated with the synchronization group.
    let objectIDs: [NSManagedObjectID]

    /// An array of `CKRecord` objects associated with the synchronization group.
    let records: [CKRecord]
}

// MARK: - Fields

extension SyncGroup: MatrixGroup {

    /// A dictionary mapping field names to their corresponding count values.
    var fields: [String: Int] {
        Dictionary(grouping: records, by: \.hourField).mapValues(\.count)
    }
}

// MARK: -

extension SyncGroup: CustomStringConvertible {
    var description: String {
        "\(name) – \(date), \(records.count) records, \(fields)"
    }
}
