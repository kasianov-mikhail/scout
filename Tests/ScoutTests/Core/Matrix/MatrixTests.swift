//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct MatrixTests {
    // MARK: - isDuplicate

    @Test("isDuplicate returns true when all identifying fields match")
    func isDuplicateMatches() {
        let date = Date(year: 2026, month: 1, day: 1)
        let lhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell(row: 0, column: 0, value: 1)]
        )
        let rhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell(row: 1, column: 1, value: 9)]
        )

        #expect(lhs.isDuplicate(of: rhs))
    }

    @Test("isDuplicate returns false when category differs")
    func isDuplicateCategoryMismatch() {
        let date = Date(year: 2026, month: 1, day: 1)
        let lhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell<Int>]()
        )
        let rhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "billing",
            cells: [GridCell<Int>]()
        )

        #expect(lhs.isDuplicate(of: rhs) == false)
    }

    @Test("isDuplicate returns false when recordType differs")
    func isDuplicateRecordTypeMismatch() {
        let date = Date(year: 2026, month: 1, day: 1)
        let lhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            cells: [GridCell<Int>]()
        )
        let rhs = GridMatrix(
            recordType: "Session",
            date: date,
            name: "login",
            cells: [GridCell<Int>]()
        )

        #expect(lhs.isDuplicate(of: rhs) == false)
    }

    // MARK: - Addition

    @Test("Addition merges duplicate cells and preserves metadata")
    func additionMergesDuplicateCells() {
        let date = Date(year: 2026, month: 1, day: 1)
        let lhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            cells: [
                GridCell(row: 0, column: 0, value: 3),
                GridCell(row: 1, column: 2, value: 5),
            ]
        )
        let rhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            cells: [
                GridCell(row: 0, column: 0, value: 4),
                GridCell(row: 2, column: 3, value: 7),
            ]
        )

        let sum = lhs + rhs

        #expect(sum.recordType == "Event")
        #expect(sum.date == date)
        #expect(sum.name == "login")
        #expect(sum.cells.count == 3)
        #expect(sum.cells[0] == GridCell(row: 0, column: 0, value: 7))
        #expect(sum.cells[1] == GridCell(row: 1, column: 2, value: 5))
        #expect(sum.cells[2] == GridCell(row: 2, column: 3, value: 7))
    }

    // MARK: - Equatable

    @Test("Equatable returns true for matrices with identical fields")
    func equatableMatches() {
        let date = Date(year: 2026, month: 1, day: 1)
        let cells = [GridCell(row: 0, column: 0, value: 1)]
        let lhs = GridMatrix(
            recordType: "Event", date: date, name: "login", cells: cells
        )
        let rhs = GridMatrix(
            recordType: "Event", date: date, name: "login", cells: cells
        )

        #expect(lhs == rhs)
    }

    @Test("Equatable returns false when cells differ")
    func equatableCellsDiffer() {
        let date = Date(year: 2026, month: 1, day: 1)
        let lhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            cells: [GridCell(row: 0, column: 0, value: 1)]
        )
        let rhs = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            cells: [GridCell(row: 0, column: 0, value: 2)]
        )

        #expect(lhs != rhs)
    }

    // MARK: - Comparable

    @Test("Comparable orders earlier dates first")
    func comparableByDate() {
        let earlier = GridMatrix(
            recordType: "Event",
            date: Date(year: 2025, month: 12, day: 31),
            name: "login",
            cells: [GridCell<Int>]()
        )
        let later = GridMatrix(
            recordType: "Event",
            date: Date(year: 2026, month: 1, day: 1),
            name: "login",
            cells: [GridCell<Int>]()
        )

        #expect(earlier < later)
    }

    @Test("Comparable orders by name when dates match")
    func comparableByName() {
        let date = Date(year: 2026, month: 1, day: 1)
        let first = GridMatrix(
            recordType: "Event",
            date: date,
            name: "apple",
            cells: [GridCell<Int>]()
        )
        let second = GridMatrix(
            recordType: "Event",
            date: date,
            name: "banana",
            cells: [GridCell<Int>]()
        )

        #expect(first < second)
    }

    @Test("Comparable orders nil category before non-nil category")
    func comparableByCategory() {
        let date = Date(year: 2026, month: 1, day: 1)
        let nilCategory = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: nil as String?,
            cells: [GridCell<Int>]()
        )
        let withCategory = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell<Int>]()
        )

        #expect(nilCategory < withCategory)
    }

    @Test("Comparable falls back to recordType")
    func comparableByRecordType() {
        let date = Date(year: 2026, month: 1, day: 1)
        let event = GridMatrix(
            recordType: "Event",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell<Int>]()
        )
        let session = GridMatrix(
            recordType: "Session",
            date: date,
            name: "login",
            category: "auth",
            cells: [GridCell<Int>]()
        )

        #expect(event < session)
    }

    @Test("Sorting multiple matrices applies full ordering")
    func sortingAppliesFullOrdering() {
        let jan = Date(year: 2026, month: 1, day: 1)
        let feb = Date(year: 2026, month: 2, day: 1)
        let a = GridMatrix(
            recordType: "Event", date: feb, name: "a", cells: [GridCell<Int>]()
        )
        let b = GridMatrix(
            recordType: "Event", date: jan, name: "b", cells: [GridCell<Int>]()
        )
        let c = GridMatrix(
            recordType: "Event", date: jan, name: "a", cells: [GridCell<Int>]()
        )

        let sorted = [a, b, c].sorted()

        #expect(sorted[0] == c)
        #expect(sorted[1] == b)
        #expect(sorted[2] == a)
    }
}
