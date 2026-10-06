//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import ScoutDBTesting
import Testing

@testable import NativeConnector

@Suite("LazyTable")
struct LazyTableTests {
    let stores = LazyTable<EntityStore>()

    private func store(over database: InMemoryDatabase) -> EntityStore {
        EntityStore(database: database, registry: SchemaRegistry(database: database))
    }

    private func publish(through store: EntityStore) async throws {
        try await store.schema("purchase").field("amount", .double).create()
    }

    @Test("An id that already has a value keeps it")
    func sharedPerID() async throws {
        let first = InMemoryDatabase()
        let second = InMemoryDatabase()

        _ = try await stores.value(id: "iCloud.Scout") { store(over: first) }
        let shared = try await stores.value(id: "iCloud.Scout") { store(over: second) }

        try await publish(through: shared)

        #expect(first.records.count == 1, "The second call reads through the value the first one left")
        #expect(second.records.count == 0)
    }

    @Test("An id of its own gets a value of its own")
    func separatePerID() async throws {
        let first = InMemoryDatabase()
        let second = InMemoryDatabase()

        let one = try await stores.value(id: "iCloud.Scout") { store(over: first) }
        let other = try await stores.value(id: "iCloud.Other") { store(over: second) }

        try await publish(through: one)
        try await publish(through: other)

        #expect(first.records.count == 1)
        #expect(second.records.count == 1)
    }

    @Test("A value is handed out only once its preparation is over")
    func waitsForPreparation() async throws {
        let database = InMemoryDatabase()

        _ = try await stores.value(id: "iCloud.Scout") {
            let prepared = store(over: database)
            try await publish(through: prepared)

            return prepared
        }

        #expect(database.records.count == 1)
    }

    @Test("A make that fails is not kept, so the next call starts over")
    func retriesAfterFailure() async throws {
        struct Fault: Error {}

        await #expect(throws: Fault.self) {
            try await stores.value(id: "iCloud.Scout") { throw Fault() }
        }

        let database = InMemoryDatabase()
        let recovered = try await stores.value(id: "iCloud.Scout") { store(over: database) }

        try await publish(through: recovered)

        #expect(database.records.count == 1)
    }
}
