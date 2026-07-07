//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Record {
    static func matrixStub(
        name: String = "matrix",
        date: Date = Date()
    ) -> Record {
        Matrix(
            date: date,
            name: name,
            cells: [
                GridCell(row: 1, column: 1, value: 3),
                GridCell(row: 2, column: 2, value: 11),
            ]
        ).record
    }
}
