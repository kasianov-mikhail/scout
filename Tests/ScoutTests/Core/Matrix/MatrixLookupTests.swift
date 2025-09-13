//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import Foundation
import CloudKit

@testable import Scout

@Suite("Matrix.lookupExisting")
struct MatrixLookupTests {
    let database = InMemoryDatabase()

    @Test func `Returns nil when no matching records`() async throws {
        database.records = [CKRecord.matrixStub(name: "other", date: Date().addingTimeInterval(-3600))]

        let matrix = Matrix<Cell<Int>>(
            recordType: "DateIntMatrix",
            date: Date(),
            name: "target",
            cells: []
        )

        let existing = try await matrix.lookupExisting(in: database)
        #expect(existing == nil)
    }

    @Test func `Returns a valid matrix when a match exists`() async throws {
        let date = Date()
        let match = CKRecord.matrixStub(name: "target", date: date)
        database.records = [match]

        let query = Matrix<Cell<Int>>(
            recordType: "DateIntMatrix",
            date: date,
            name: "target",
            cells: []
        )

        let existing = try #require(try await query.lookupExisting(in: database))
        let parsed = try Matrix<Cell<Int>>(record: match)

        #expect(existing.recordType == "DateIntMatrix")
        #expect(existing.name == "target")
        #expect(existing.date == date)
        #expect(Set(existing.cells) == Set(parsed.cells))
    }
}
