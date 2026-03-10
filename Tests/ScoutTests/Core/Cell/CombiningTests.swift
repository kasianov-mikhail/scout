//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct CombiningTests {

    // MARK: - mergeDuplicates

    @Test("Merge duplicates combines matching cells")
    func mergeDuplicates() {
        let cells = [
            GridCell(row: 1, column: 2, value: 3),
            GridCell(row: 1, column: 2, value: 4),
            GridCell(row: 3, column: 4, value: 5),
        ]

        let merged = cells.mergeDuplicates()

        #expect(merged.count == 2)
        #expect(merged[0] == GridCell(row: 1, column: 2, value: 7))
        #expect(merged[1] == GridCell(row: 3, column: 4, value: 5))
    }

    @Test("Merge duplicates with no duplicates")
    func mergeDuplicatesNoDuplicates() {
        let cells = [
            GridCell(row: 1, column: 1, value: 1),
            GridCell(row: 2, column: 2, value: 2),
            GridCell(row: 3, column: 3, value: 3),
        ]

        let merged = cells.mergeDuplicates()

        #expect(merged.count == 3)
    }

    @Test("Merge duplicates with all duplicates")
    func mergeDuplicatesAllSame() {
        let cells = [
            GridCell(row: 0, column: 0, value: 1),
            GridCell(row: 0, column: 0, value: 2),
            GridCell(row: 0, column: 0, value: 3),
        ]

        let merged = cells.mergeDuplicates()

        #expect(merged.count == 1)
        #expect(merged[0] == GridCell(row: 0, column: 0, value: 6))
    }

    @Test("Merge duplicates on empty array")
    func mergeDuplicatesEmpty() {
        let cells: [GridCell<Int>] = []
        let merged = cells.mergeDuplicates()
        #expect(merged.isEmpty)
    }

    @Test("Merge duplicates preserves order of first occurrence")
    func mergeDuplicatesOrder() {
        let cells = [
            GridCell(row: 2, column: 0, value: 10),
            GridCell(row: 1, column: 0, value: 5),
            GridCell(row: 2, column: 0, value: 20),
        ]

        let merged = cells.mergeDuplicates()

        #expect(merged.count == 2)
        #expect(merged[0] == GridCell(row: 2, column: 0, value: 30))
        #expect(merged[1] == GridCell(row: 1, column: 0, value: 5))
    }
}
