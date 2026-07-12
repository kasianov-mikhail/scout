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
        let registration = Task { await EntityCatalog.register(into: registry) }

        return Backend(
            id: container.containerIdentifier ?? "cloudKit",
            database: NativeDatabase(store: store, registration: registration),
            checkAvailability: {
                (try? await container.accountStatus()) == .available
            },
            displayName: "iCloud",
            probeStatus: {
                do {
                    return try await container.accountStatus().backendStatus
                } catch {
                    return .failed(error)
                }
            },
            accountWarning: {
                switch try await container.accountStatus() {
                case .available:
                    return nil
                case .noAccount:
                    return .noAccount
                case .restricted:
                    return .restricted
                case .temporarilyUnavailable:
                    return .temporarilyUnavailable
                case .couldNotDetermine:
                    return .couldNotDetermine
                @unknown default:
                    return .couldNotDetermine
                }
            },
            onSetup: {
                Task {
                    await EntityCatalog.reconcile(registry: registry, database: container.publicCloudDatabase)
                }
            }
        )
    }
}

extension CKAccountStatus {
    var backendStatus: Backend.Status {
        switch self {
        case .available:
            .reachable
        case .noAccount, .restricted, .temporarilyUnavailable:
            .readOnly
        case .couldNotDetermine:
            .unreachable
        @unknown default:
            .unreachable
        }
    }
}

extension EntityCatalog {
    static func register(into registry: SchemaRegistry) async {
        for definition in definitions {
            try? await registry.register(definition)
        }
    }

    static func reconcile(registry: SchemaRegistry, database: any CloudDatabase) async {
        // Read the published schema through a throwaway registry so preload never
        // overwrites the authoritative local definitions already in `registry`.
        let mirror = SchemaRegistry(database: database)
        _ = try? await mirror.preload()
        let remote = await mirror.definitions()

        for definition in definitions {
            let published = remote.first { $0.entity == definition.entity }

            if let published, published.version > definition.version {
                continue
            }
            if published != definition {
                try? await registry.publish(definition)
            }
        }
    }
}
