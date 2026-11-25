//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout
import ScoutDB

private let stores = LazyTable<NativeDatabase.Storage>()

struct NativeDatabase: Sendable {
    struct Storage: Sendable {
        let store: EntityStore
        let registry: SchemaRegistry
    }

    let resolveStorage: @Sendable () async throws -> Storage
    let flights = SeriesFlights()

    func resolve() async throws -> EntityStore {
        try await resolveStorage().store
    }
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
        let storage = NativeDatabase.Storage(store: store, registry: registry)
        let database = NativeDatabase {
            do {
                return try await stores.value(id: id) {
                    try await container.accountStatus().verify()
                    try await CatalogEntry.publishAll(into: store, registry: registry)
                    return storage
                }
            } catch is Backend.AccountError {
                // Keep public reads available and let the next resolve retry publication.
                return storage
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
