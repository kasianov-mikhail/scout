//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct SyncGroup<T: Syncable>: @unchecked Sendable {
    let matrix: Matrix<T.Cell>
    let representables: [CKRepresentable]?
    let batch: [T]
}

extension SyncGroup: CustomStringConvertible {
    var description: String {
        """
        SyncGroup(
          recordType: "\(matrix.recordType)",
          name: "\(matrix.name)",
          date: \(matrix.date),
          batch: \(batch.count) items,
        )
        """
    }
}
