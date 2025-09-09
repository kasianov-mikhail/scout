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
            recordType: "DateIntMatrix",
            name: "group_name",
            category: nil,
            date: now,
            representables: nil,
            batch: [
                .stub(name: "A", in: context),
                .stub(name: "A", in: context)
            ]
        )
    }

    @Test("Create a new matrix") func testNewMatrix() async throws {
        let matrix = group.newMatrix()

        #expect(group.name == matrix.name)
        #expect(group.date == matrix.date)
        #expect(!matrix.cells.isEmpty)
    }

    @Test("Retrieve an existing matrix") func testMatrix() async throws {
        database.records = [.matrixStub(name: group.name, date: group.date)]

        let matrix = try await group.matrix(in: database)

        #expect(group.name == matrix.name)
        #expect(group.date == matrix.date)
    }
}

private let now = Date()
