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

@Test("GridCell parses a valid key") func testValidKey() throws {
    let cell = try GridCell<Int>(key: "cell_1_02", value: 5)
    #expect(cell == GridCell(row: 1, column: 2, value: 5))
}

@Test("GridCell throws on a malformed key instead of crashing") func testMalformedKey() {
    #expect(throws: CellKeyError.self) { try GridCell<Int>(key: "cell_1", value: 5) }
    #expect(throws: CellKeyError.self) { try GridCell<Int>(key: "cell_x_02", value: 5) }
    #expect(throws: CellKeyError.self) { try GridCell<Int>(key: "cell_1_zz", value: 5) }
}
