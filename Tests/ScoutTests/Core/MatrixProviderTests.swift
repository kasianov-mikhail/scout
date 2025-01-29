//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing
import CloudKit

@testable import Scout

struct MatrixProviderTests {
    struct TestProvider: MatrixProvider {
        let name: String
        let date: Date
        let keys: [String] = []
    }

    let group = TestProvider(name: "group_name", date: Date())

    @Test("Create a new matrix") func testNewMatrix() async throws {
        let matrix = group.newMatrix()

        #expect(group.name == matrix["name"])
        #expect(group.date == matrix["date"])
    }

    @Test("Retrieve an existing matrix") func testMatrix() async throws {
        let database = InMemoryDatabase()

        let record = CKRecord(recordType: "DateIntMatrix")
        record["name"] = group.name
        record["date"] = group.date
        database.records = [record]

        let matrix = try await group.matrix(in: database)

        #expect(group.name == matrix["name"])
        #expect(group.date == matrix["date"])
    }
}
