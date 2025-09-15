//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Test("GridCell addition") func testCellAddition() {
    let a = GridCell(row: 1, column: 2, value: 3)
    let b = GridCell(row: 1, column: 2, value: 4)
    let c = a + b

    #expect(c == GridCell(row: 1, column: 2, value: 7))
}
