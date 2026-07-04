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
            database: NativeDatabase(store: store),
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
            onSetup: {
                Task {
                    await EntityCatalog.bootstrap(registry: registry)
                }
            }
        )
    }
}

extension EntityCatalog {
    static func bootstrap(registry: SchemaRegistry) async {
        _ = try? await registry.preload()
        let remote = await registry.definitions()

        for definition in definitions {
            let published = remote.first { $0.entity == definition.entity }

            if let published, published.version > definition.version {
                continue
            }

            try? await registry.register(definition)

            if published != definition {
                await publish(definition, in: registry)
            }
        }
    }

    private static func publish(_ definition: EntityDefinition, in registry: SchemaRegistry) async {
        do {
            try await registry.publish(definition)
        } catch {
            await MainActor.run { schemaBootstrapMessage.value = error.localizedDescription }
        }
    }
}
