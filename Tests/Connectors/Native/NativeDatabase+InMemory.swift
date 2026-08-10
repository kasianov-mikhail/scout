//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import ScoutDBTesting

@testable import NativeConnector

extension NativeDatabase {
    // The store resolves a schema by reading its published descriptor, so a
    // suite has to publish the catalog before it can write anything.
    static func inMemory() -> NativeDatabase {
        let cloud = InMemoryDatabase()
        let registry = SchemaRegistry(database: cloud)
        let store = EntityStore(database: cloud, registry: registry)

        let registration = Task { await publishCatalog(into: store, registry: registry) }

        return NativeDatabase {
            await registration.value
            return store
        }
    }

    static func publishCatalog(into store: EntityStore, registry: SchemaRegistry) async {
        for entry in CatalogEntry.entries {
            try? await entry.publish(into: store, registry: registry)
        }
    }
}
