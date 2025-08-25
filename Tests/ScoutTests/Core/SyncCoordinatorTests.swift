//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

private let recordType = "DateIntMatrix"
private let now = Date()

@MainActor
struct SyncCoordinatorTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let coordinator: SyncCoordinator<Int>

    init() throws {
        let group = SyncGroup(
            recordType: recordType,
            name: "Test",
            date: now,
            objects: [],
            fields: ["cell_1_01": 5, "cell_2_02": 10]
        )

        coordinator = SyncCoordinator(
            database: database,
            maxRetry: 3,
            group: group
        )
    }

    @Test("Test successful upload") func testUpload() async throws {
        try await coordinator.upload()

        #expect(database.matrices.count == 1)
        #expect(database.matrices.first?["cell_1_01"] == 5)
        #expect(database.matrices.first?["cell_2_02"] == 10)
    }

    @Test("Test successful merge") func testMergeError() async throws {
        database.errors.append(createMergeError())

        try await coordinator.upload()

        #expect(database.matrices.count == 1)
        #expect(database.matrices.first?["cell_1_01"] == 8)
        #expect(database.matrices.first?["cell_2_02"] == 21)
    }

    @Test("Create a new matrix, if there are repeating merge errors") func testNewMatrix()
        async throws
    {
        database.errors.append(contentsOf: Array(repeating: createMergeError(), count: 4))

        try await coordinator.upload()

        #expect(database.matrices.count == 1)
        #expect(database.matrices.first?["cell_1_01"] == 5)
        #expect(database.matrices.first?["cell_2_02"] == 10)
    }
}

private func createMergeError() -> Error {
    let serverMatrix = CKRecord(recordType: "DateIntMatrix")
    serverMatrix["name"] = "Test"
    serverMatrix["date"] = now
    serverMatrix["cell_1_01"] = 3
    serverMatrix["cell_2_02"] = 11
    return CKError(
        CKError.Code.serverRecordChanged,
        userInfo: [CKRecordChangedErrorServerRecordKey: serverMatrix]
    )
}

extension InMemoryDatabase {
    fileprivate var matrices: [CKRecord] {
        records.filter { $0.recordType == recordType }
    }
}
