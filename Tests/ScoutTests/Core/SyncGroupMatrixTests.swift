//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import CloudKit

@testable import Scout

struct SyncGroupMatrixTests {

    @Test("Create a new matrix") func testNewMatrix() async throws {
        let group = SyncGroup(name: "group_name", week: Date(), events: [])
        let matrix = group.newMatrix()

        #expect(group.name == matrix["name"])
        #expect(group.week == matrix["date"])
    }

    @Test("Retrieve an existing matrix") func testMatrix() async throws {
        let database = InMemoryDatabase()
        let group = SyncGroup(name: "group_name", week: Date(), events: [])

        let record = CKRecord(recordType: "DateIntMatrix")
        record["name"] = group.name
        record["date"] = group.week
        database.records = [record]

        let matrix = try await group.matrix(in: database)

        #expect(group.name == matrix["name"])
        #expect(group.week == matrix["date"])
    }
}
