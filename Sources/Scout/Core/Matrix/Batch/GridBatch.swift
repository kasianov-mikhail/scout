//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// A `MatrixBatch` for lifecycle objects that produce a `GridMatrix<Int>`
/// named after the object's `recordType`.
protocol GridBatch: MatrixBatch & RecordTyped & CKRepresentable where Cell == GridCell<Int> {}

extension GridBatch where Self: Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [Self]? {
        try batch(in: context, matching: [\.week])
    }
}

extension GridBatch where Self: DateObject {
    static func matrix(of batch: [Self]) throws(MatrixPropertyError) -> GridMatrix<Int> {
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
