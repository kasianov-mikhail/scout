//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import Testing

@testable import Scout

struct ChartPointTests {
    @Test("Mapping an integer matrix to chart points") func testFromIntMatrix() {
        let date = Date()
        let matrix = Matrix(
            date: date,
            name: "Test",
            category: nil,
            recordID: CKRecord.ID(recordName: "Test"),
            cells: [
                Cell(row: 2, column: 0, value: 5),
                Cell(row: 1, column: 1, value: 10),
            ])

        let points = ChartPoint.fromIntMatrix(matrix)

        let expected = [
            ChartPoint(date: date.addingDay(1).addingHour(0), count: 5),
            ChartPoint(date: date.addingDay(0).addingHour(1), count: 10),
        ]
        #expect(points == expected)
    }
}
