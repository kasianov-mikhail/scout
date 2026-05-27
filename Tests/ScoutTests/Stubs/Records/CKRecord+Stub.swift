//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@testable import Scout

extension CKRecord {
    static func matrixStub(
        name: String = "matrix",
        date: Date = Date()
    ) -> CKRecord {
        let matrix = CKRecord(recordType: Int.recordType)
        matrix["name"] = name
        matrix["date"] = date
        matrix["cell_1_01"] = 3
        matrix["cell_2_02"] = 11
        return matrix
    }
}
