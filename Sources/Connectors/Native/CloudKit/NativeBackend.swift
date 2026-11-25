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

        let registry = SchemaRegistry(database: container.publicCloudDatabase)
        let store = EntityStore(database: container.publicCloudDatabase, registry: registry)
        let database = NativeDatabase {
            do {
                return try await stores.value(id: id) {
                    try await container.accountStatus().verify()
                    try await CatalogEntry.publishAll(into: store, registry: registry)
                    return store
                }
            } catch is Backend.AccountError {
                // Keep public reads available and let the next resolve retry publication.
                return store
            }
        }

        return Backend(
            id: id,
            database: database,
            displayName: "iCloud",
            engine: .cloudKit,
            checkAccess: { try await container.accountStatus().verify() }
        )
    }
}
