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

@MainActor
@Suite("SyncCoordinator")
struct SyncCoordinatorTests {
    let database = InMemoryDatabase()
    let context = NSManagedObjectContext.inMemoryContext()
    let coordinator: SyncCoordinator<EventObject>

    init() {
        let group = SyncGroup(
            recordType: "DateIntMatrix",
            name: "matrix",
            date: now,
            representables: nil,
            batch: [
                createEvent(name: "A", in: context),
                createEvent(name: "A", in: context),
            ]
        )
        coordinator = SyncCoordinator(
            database: database,
            maxRetry: 3,
            group: group
        )
    }

    @Test("Successful upload calls save on the database")
    func testUploadSuccess() async throws {
        try await coordinator.upload()

        #expect(database.records.filter { $0.recordType == "DateIntMatrix" }.count == 1)
    }

    @Test("Upload retries and merges on serverRecordChanged error")
    func testUploadServerRecordChangedMerges() async throws {
        database.errors.append(createMergeError())

        try await coordinator.upload()

        #expect(database.records.filter { $0.recordType == "DateIntMatrix" }.count == 1)
    }

    @Test("Upload falls back to newMatrix after max retries")
    func testUploadMaxRetryFallback() async throws {
        for _ in 0..<(coordinator.maxRetry + 1) {
            database.errors.append(createMergeError())
        }
        try await coordinator.upload()

        #expect(database.records.filter { $0.recordType == "DateIntMatrix" }.count == 1)
    }
}

private let now = Date()

private func createMergeError() -> Error {
    let serverMatrix = CKRecord(recordType: "DateIntMatrix")
    serverMatrix["name"] = "matrix"
    serverMatrix["date"] = now
    serverMatrix["cell_1_01"] = 3
    serverMatrix["cell_2_02"] = 11
    return CKError(
        CKError.Code.serverRecordChanged,
        userInfo: [CKRecordChangedErrorServerRecordKey: serverMatrix]
    )
}

private func createEvent(name: String, in context: NSManagedObjectContext) -> EventObject {
    let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
    let event = EventObject(entity: entity, insertInto: context)
    event.name = name
    event.date = now
    return event
}
