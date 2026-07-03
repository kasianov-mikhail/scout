//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import ScoutDB

extension Backend {
    /// A CloudKit backend that stores records through scout-db's frozen Item/GridItem
    /// schema.
    ///
    /// Raw records are delivered to every entity; chart aggregates are maintained by
    /// scout-db views on write, so no client-side matrix upload happens.
    ///
    public static func cloudKit(container: CKContainer) -> Backend {
        let registry = SchemaRegistry(database: container.publicCloudDatabase)
        let store = EntityStore(database: container.publicCloudDatabase, registry: registry)

        return Backend(
            id: container.containerIdentifier ?? "cloudKit",
            database: ScoutDBDatabase(store: store),
            checkAvailability: {
                (try? await container.accountStatus()) == .available
            },
            displayName: "iCloud",
            probeStatus: {
                let status = try? await container.accountStatus()
                return status == .available ? .reachable : .unreachable
            },
            accountWarning: {
                (try? await container.accountStatus()) != .available
            },
            verifySchema: { try await container.verifySchema(for: storeRecordTypes) },
            schemaChecks: { await container.schemaChecks(for: storeRecordTypes) },
            onSetup: {
                Task {
                    await EntityCatalog.bootstrap(registry: registry)
                }
            }
        )
    }
}

// The record types of scout-db's frozen physical schema.
private let storeRecordTypes = ["Item", "GridItem", "Meta"]

extension EntityCatalog {
    // Seeds the registry with the app-embedded definitions and publishes them to
    // Meta so external readers of the container can decode the records too.
    static func bootstrap(registry: SchemaRegistry) async {
        _ = try? await registry.preload()
        let remote = await registry.definitions()

        for definition in definitions {
            guard let published = remote.first(where: { $0.entity == definition.entity }) else {
                try? await registry.register(definition)
                try? await registry.publish(definition)
                continue
            }
            guard published.version <= definition.version else { continue }
            try? await registry.register(definition)
            if published != definition {
                try? await registry.publish(definition)
            }
        }
    }
}
