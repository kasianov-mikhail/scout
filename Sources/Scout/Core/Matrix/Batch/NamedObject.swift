//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// `TrackedObject` with a user-facing `name` attribute and a shared
/// `matrix(of:)` that groups records by their own `name`.
///
/// Base for `EventObject` and `CrashObject` — both aggregate by event name
/// (e.g. "login", "fatal") rather than by `recordType`.
///
@objc(NamedObject)
class NamedObject: TrackedObject, MatrixBatch {
    @NSManaged var name: String?

    static func matrix(of batch: [NamedObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        guard let name = batch.first?.name else {
            throw .init("name")
        }
        guard let week = batch.first?.week else {
            throw .init("week")
        }
        return Matrix(
            recordType: Int.recordType,
            date: week,
            name: name,
            cells: parse(of: batch)
        )
    }
}
