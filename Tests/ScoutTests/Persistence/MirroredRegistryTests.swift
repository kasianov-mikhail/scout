//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("MirroredRegistry")
struct MirroredRegistryTests {
    let store = MockRegistry()
    let mirror = MockRegistry()

    var registry: MirroredRegistry {
        MirroredRegistry(store: store, mirror: mirror)
    }

    @Test("Prefers the store and copies what it returns into the mirror")
    func prefersStore() {
        let uuid = UUID()
        store.storage["device"] = uuid

        #expect(registry.resolve("device") == uuid)
        #expect(mirror.storage["device"] == uuid)
    }

    @Test("Keeps the mirrored ID instead of minting when the store has no answer")
    func fallsBackToMirror() {
        let uuid = UUID()
        mirror.storage["device"] = uuid

        #expect(registry.ensure("device") == uuid)
        #expect(store.storage["device"] == uuid)
    }

    @Test("Overwrites a stale mirror with the stored ID")
    func healsMirror() {
        let uuid = UUID()
        store.storage["device"] = uuid
        mirror.storage["device"] = UUID()

        #expect(registry.resolve("device") == uuid)
        #expect(mirror.storage["device"] == uuid)
    }

    @Test("Mints into both sides when neither knows the key")
    func mintsIntoBoth() {
        let uuid = registry.ensure("device")

        #expect(store.storage["device"] == uuid)
        #expect(mirror.storage["device"] == uuid)
    }

    @Test("Returns the same ID on repeated calls")
    func idempotent() {
        #expect(registry.ensure("device") == registry.ensure("device"))
    }
}
