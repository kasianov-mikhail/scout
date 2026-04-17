//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// A `MatrixBatch` of weekly lifecycle records
/// (`DeviceObject`, `InstallObject`, `LaunchObject`, `SessionObject`,
/// `VersionObject`).
///
/// Provides defaults for all three steps of the sync pipeline:
/// - `group(in:)` — fetches all unsynced records sharing a week,
/// - `parse(of:)` — groups them by hour-of-week and counts them,
/// - `matrix(of:)` — wraps the cells in a `GridMatrix<Int>` named after
///   the object's `recordType`.
///
/// Conformers only declare their `recordType` and `toRecord` — everything
/// else is inherited.
///
protocol GridBatch: MatrixBatch & RecordTyped & CKRepresentable where Cell == GridCell<Int> {}

extension GridBatch where Self: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [Self]? {
        try batch(in: context, matching: [\.week])
    }
}

extension GridBatch where Self: DateObject {
    static func matrix(of batch: [Self]) throws -> GridMatrix<Int> {
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: Int.recordType,
            date: week,
            name: Self.recordType,
            cells: parse(of: batch)
        )
    }
}
