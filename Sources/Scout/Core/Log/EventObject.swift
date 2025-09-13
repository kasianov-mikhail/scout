//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(EventObject)
final class EventObject: TrackedObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<EventObject>? {
        guard let batch: [EventObject] = try batch(in: context, matching: [\.name, \.week]) else {
            return nil
        }
        guard let name = batch.first?.name, let week = batch.first?.week else {
            return nil
        }
        return SyncGroup(
            matrix: Matrix(
                recordType: "DateIntMatrix",
                date: week,
                name: name,
                cells: []
            ),
            representables: batch,
            batch: batch
        )
    }

    static func parse(of batch: [EventObject]) -> [Cell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(Cell.init)
    }
}
