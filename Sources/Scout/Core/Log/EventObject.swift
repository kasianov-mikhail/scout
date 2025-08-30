//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(EventObject)
final class EventObject: TrackedObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<EventObject>? {
        guard let batch = try BatchProvider<EventObject>(context: context, keyPaths: [\.name, \.week]).batch() else {
            return nil
        }
        return SyncGroup(
            recordType: "DateIntMatrix",
            name: batch[0].name!,
            date: batch[0].week!,
            representables: batch,
            batch: batch
        )
    }

    static func parse(of batch: [EventObject]) -> [Cell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(Cell.init)
    }
}
