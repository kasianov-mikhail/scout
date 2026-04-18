//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// Groups weekly lifecycle records into matrices for syncing.
///
/// Conformers only need to declare `recordType` and `toRecord`;
/// all batch grouping and parsing is inherited.
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
            throw MatrixPropertyError("week")
        }
        return Matrix(
            recordType: Int.recordType,
            date: week,
            name: Self.recordType,
            cells: parse(of: batch)
        )
    }
}
