//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SessionObject)
final class SessionObject: SyncableObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<SessionObject>? {
        guard let batch: [SessionObject] = try batch(in: context, matching: [\.week]) else {
            return nil
        }
        guard let week = batch.first?.week else {
            return nil
        }
        return SyncGroup(
            recordType: "DateIntMatrix",
            name: "Session",
            category: nil,
            date: week,
            representables: batch,
            batch: batch
        )
    }

    static func parse(of batch: [SessionObject]) -> [Cell<Int>] {
        batch.grouped(by: \.date).mapValues(\.count).map(Cell.init)
    }
}
