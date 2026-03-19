//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(NamedObject)
class NamedObject: SyncableObject {

    @NSManaged var name: String?

    static func matrix(of batch: [NamedObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
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

    static func parse(of batch: [NamedObject]) -> [GridCell<Int>] {
        batch.grouped(by: \.hour).mapValues(\.count).map(GridCell.init)
    }
}
