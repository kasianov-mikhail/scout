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

@MainActor struct SyncCoordinatorTests {
    let database = InMemoryDatabase()
    let event = EventModel(context: .inMemoryContext())

    let group: SyncGroup
    let coordinator: SyncCoordinator

    init() {
        event.name = "event_name"
        event.hour = Date()

        group = SyncGroup(
            name: "test",
            week: Date(),
            events: [event]
        )

        coordinator = SyncCoordinator(
            database: database,
            maxRetry: 3,
            group: group
        )
    }

    @Test("Test successful upload") func testUpload() async throws {
        try await coordinator.upload()

        #expect(database.events.count == 1)
        #expect(database.events.first?["name"] == "event_name")
    }

    @Test("Test successful merge") func testMergeError() async throws {
        database.errors.append(createMergeError())

        try await coordinator.upload()

        #expect(database.events.count == 1)
        #expect(database.events.first?["name"] == "event_name")
    }

    @Test("Create a new matrix, if there are repeating merge errors") func testNewMatrix() async throws {
        database.errors.append(contentsOf: Array(repeating: createMergeError(), count: 4))

        try await coordinator.upload()

        #expect(database.events.count == 1)
        #expect(database.events.first?["name"] == "event_name")
    }
}

extension SyncCoordinatorTests {
    fileprivate func createMergeError() -> Error {
        CKError(
            CKError.Code.serverRecordChanged,
            userInfo: [CKRecordChangedErrorServerRecordKey: CKRecord(recordType: "DateIntMatrix")]
        )
    }
}
