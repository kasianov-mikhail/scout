//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(EventObject)
final class EventObject: SyncableObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [EventObject]? {
        try batch(in: context, matching: [\.name, \.week])
    }
}

extension EventObject: MatrixBatch {
    static func matrix(of batch: [EventObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        guard let name = batch.first?.name else {
            throw .init("name")
        }
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: "DateIntMatrix",
            date: week,
            name: name,
            cells: parse(of: batch)
        )
    }

    static func parse(of batch: [EventObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(Cell.init)
    }
}

