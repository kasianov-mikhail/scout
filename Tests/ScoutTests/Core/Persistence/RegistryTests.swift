//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RegistryTests {
    let store = MockRegistry()

    @Test("Returns existing UUID for key")
    func existingKey() {
        let uuid = UUID()
        store.storage["key"] = uuid
        #expect(store.ensure("key") == uuid)
    }

    @Test("Creates and stores UUID for missing key")
    func missingKey() {
        let result = store.ensure("new")
        #expect(store.storage["new"] == result)
    }

    @Test("Returns same UUID on repeated calls")
    func idempotent() {
        let first = store.ensure("key")
        let second = store.ensure("key")
        #expect(first == second)
    }
}

final class MockRegistry: Registry {
    var storage: [String: UUID] = [:]

    func resolve(_ key: String) -> UUID? {
        storage[key]
    }

    func register(_ value: UUID, for key: String) {
        storage[key] = value
    }
}
