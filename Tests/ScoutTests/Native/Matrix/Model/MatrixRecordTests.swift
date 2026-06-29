//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("Matrix+Record")
struct MatrixRecordTests {
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("Round-trips the app version through the record")
    func testVersionRoundTrip() throws {
        let matrix = Matrix<GridCell<Int>>(
            date: date,
            name: "Session",
            version: "3.2.0",
            cells: [GridCell(row: 1, column: 0, value: 5)]
        )

        let decoded = try Matrix<GridCell<Int>>(record: matrix.record)

        #expect(decoded.version == "3.2.0")
        #expect(decoded.category == nil)
    }

    @Test("Keeps version and category independent")
    func testVersionIndependentOfCategory() throws {
        let matrix = Matrix<GridCell<Int>>(
            date: date,
            name: "metric",
            category: "counter",
            cells: [GridCell(row: 1, column: 0, value: 1)]
        )

        let decoded = try Matrix<GridCell<Int>>(record: matrix.record)

        #expect(decoded.category == "counter")
        #expect(decoded.version == nil)
    }
}
