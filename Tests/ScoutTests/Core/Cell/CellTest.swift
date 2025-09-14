//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Test("Cell addition") func testCellAddition() {
    let a = Cell(row: 1, column: 2, value: 3)
    let b = Cell(row: 1, column: 2, value: 4)
    let c = a + b

    #expect(c == Cell(row: 1, column: 2, value: 7))
}
