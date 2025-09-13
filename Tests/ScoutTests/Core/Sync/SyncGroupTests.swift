//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

@Suite("SyncGroup")
struct SyncGroupTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let group: SyncGroup<EventObject>

    init() {
        group = SyncGroup<EventObject>(
            matrix: Matrix(
                recordType: "DateIntMatrix",
                date: now,
                name: "group_name",
                cells: []
            ),
            representables: nil,
            batch: [
                .stub(name: "A", in: context),
                .stub(name: "A", in: context),
            ]
        )
    }

    @Test("Create a new matrix") func testNewMatrix() async throws {
        let matrix = group.newMatrix()

        #expect(group.matrix.name == matrix.name)
        #expect(group.matrix.date == matrix.date)
        #expect(!matrix.cells.isEmpty)
    }

    @Test("Retrieve an existing matrix") func testMatrix() async throws {
        database.records = [.matrixStub(name: group.matrix.name, date: group.matrix.date)]

        let matrix = try await group.matrix(in: database)

        #expect(group.matrix.name == matrix.name)
        #expect(group.matrix.date == matrix.date)
    }
}

private let now = Date()
