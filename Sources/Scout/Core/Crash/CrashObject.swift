//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(CrashObject)
final class CrashObject: NamedObject, Syncable, MatrixBatch {
    static func group(in context: NSManagedObjectContext) throws -> [CrashObject]? {
        try batch(in: context, matching: [\.name, \.week])
    }

    static func matrix(of batch: [CrashObject]) throws(MatrixPropertyError) -> GridMatrix<Int> {
        try NamedObject.matrix(of: batch)
    }
}
