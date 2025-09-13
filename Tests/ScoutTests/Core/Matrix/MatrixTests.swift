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

struct MatrixTests {

    @Test("Matrix initialization from CKRecord") func testMatrixInitialization() throws {
        let record = CKRecord(recordType: "DateIntMatrix")
        let date = Date()
        record["date"] = date
        record["name"] = "Test Matrix"
        record["cell_0_0"] = 1
        record["cell_0_1"] = 2

        let matrix = try Matrix<Cell<Int>>(record: record)
        let expectedCells = [
            Cell(row: 0, column: 0, value: 1),
            Cell(row: 0, column: 1, value: 2),
        ]

        #expect(Set(matrix.cells) == Set(expectedCells))
    }

    @Test("Matrix addition") func testMatrixAddition() {
        let date = Date()
        var matrix1 = Matrix(
            recordType: "DateIntMatrix",
            date: date,
            name: "Test Matrix",
            cells: [Cell(row: 0, column: 0, value: 1)]
        )
        let matrix2 = Matrix(
            recordType: "DateIntMatrix",
            date: date,
            name: "Test Matrix",
            cells: [Cell(row: 0, column: 0, value: 2)]
        )

        matrix1 += matrix2

        #expect(matrix1.cells.count == 1)
        #expect(matrix1.cells.first?.value == 3)
    }

    @Test("Matrix cell addition") func testMatrixCellAddition() {
        var cell1 = Cell(row: 0, column: 0, value: 1)
        let cell2 = Cell(row: 0, column: 0, value: 2)

        cell1 += cell2

        #expect(cell1.value == 3)
    }

    @Test("Merge duplicate matrices") func testMergeDuplicateMatrices() {
        let date = Date()
        let matrix1 = Matrix(
            recordType: "DateIntMatrix",
            date: date,
            name: "Test Matrix",
            category: "A",
            recordID: CKRecord.ID(recordName: "1"),
            cells: [Cell(row: 0, column: 0, value: 1)]
        )
        let matrix2 = Matrix(
            recordType: "DateIntMatrix",
            date: date,
            name: "Test Matrix",
            category: "A",
            recordID: CKRecord.ID(recordName: "2"),
            cells: [Cell(row: 0, column: 0, value: 2)]
        )

        let merged = [matrix1, matrix2].mergeDuplicates()

        #expect(merged.count == 1)
        #expect(merged.first?.cells.count == 1)
        #expect(merged.first?.cells.first?.value == 3)
    }

    @Test("Merge duplicate cells") func testMergeDuplicateCells() {
        let cell1 = Cell(row: 0, column: 0, value: 1)
        let cell2 = Cell(row: 0, column: 0, value: 2)

        let merged = [cell1, cell2].mergeDuplicates()

        #expect(merged.count == 1)
        #expect(merged.first?.value == 3)
    }
}
