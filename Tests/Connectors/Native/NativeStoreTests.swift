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

@Suite("NativeStore")
struct NativeStoreTests {
    private func makeDatabase() -> NativeDatabase {
        let database = InMemoryDatabase()
        let registry = SchemaRegistry(database: database)

        return NativeDatabase(store: EntityStore(database: database, registry: registry))
    }

    @Test("A container that already has a store keeps it, however often it is asked for")
    func sharedPerContainer() {
        var built = 0
        let id = "iCloud.\(UUID().uuidString)"

        for _ in 0..<3 {
            _ = NativeStore.shared(id: id) {
                built += 1
                return makeDatabase()
            }
        }

        #expect(built == 1)
    }

    @Test("A container of its own gets a store of its own")
    func separatePerContainer() {
        var built = 0

        for _ in 0..<2 {
            _ = NativeStore.shared(id: "iCloud.\(UUID().uuidString)") {
                built += 1
                return makeDatabase()
            }
        }

        #expect(built == 2)
    }
}
