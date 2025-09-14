//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(SessionObject)
final class SessionObject: SyncableObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [SessionObject]? {
        try batch(in: context, matching: [\.week])
    }

    static func matrix(of batch: [SessionObject]) throws(SyncableError) -> Matrix<Cell<Int>> {
        guard let week = batch.first?.week else {
            throw .missingProperty("week")
        }
        return Matrix(
            recordType: "DateIntMatrix",
            date: week,
            name: "Session",
            cells: parse(of: batch)
        )
    }

    static func parse(of batch: [SessionObject]) -> [Cell<Int>] {
        batch.grouped(by: \.date).mapValues(\.count).map(Cell.init)
    }
}
