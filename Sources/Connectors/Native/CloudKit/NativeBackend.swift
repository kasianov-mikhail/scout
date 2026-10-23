//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout
import ScoutDB

private let stores = LazyTable<EntityStore>()

struct NativeDatabase: Sendable {
    let resolve: @Sendable () async throws -> EntityStore
    let flights = SeriesFlights()
}

extension Backend {
    struct UnidentifiedContainerError: LocalizedError {
        let errorDescription: String? = "The CloudKit container carries no identifier"
    }

    public static func cloudKit(container: CKContainer) throws -> Backend {
        guard let id = container.containerIdentifier else {
            throw UnidentifiedContainerError()
        }

        let database = NativeDatabase {
            try await stores.value(id: id) {
                try await container.publishedStore()
            }
        }

        return Backend(
            id: id,
            database: database,
            displayName: "iCloud",
            engine: .cloudKit,
            checkAccess: {
                try await container.accountStatus().verify()
            }
        )
    }
}

extension CKContainer {
    fileprivate func publishedStore() async throws -> EntityStore {
        let registry = SchemaRegistry(database: publicCloudDatabase)
        let store = EntityStore(database: publicCloudDatabase, registry: registry)

        try await CatalogEntry.publishAll(into: store, registry: registry)

        return store
    }
}
