//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout
import ScoutDB

extension Backend {
    /// A CloudKit backend that stores records through scout-db's frozen Entity/Vector
    /// schema.
    ///
    /// Raw records are delivered to every entity; chart aggregates are maintained by
    /// scout-db vectors on write, so no client-side matrix upload happens.
    ///
    public static func cloudKit(container: CKContainer) -> Backend {
        let registry = SchemaRegistry(database: container.publicCloudDatabase)
        let store = EntityStore(database: container.publicCloudDatabase, registry: registry)
        let registration = Task { await EntityCatalog.publish(into: store, registry: registry) }

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
    // The store resolves a schema by reading its published descriptor, so
    // nothing can be written until one exists. Publishing runs once per launch
    // ahead of the first write, and costs a read per entity — the same read the
    // write would pay anyway — plus a write only where the declaration drifted.
    static func publish(into store: EntityStore, registry: SchemaRegistry) async {
        for entry in entries {
            try? await entry.publish(into: store, registry: registry)
        }
    }
}

extension CatalogEntry {
    func publish(into store: EntityStore, registry: SchemaRegistry) async throws {
        let declaration = declaration(on: store)

        guard let published = try? await registry.schema(for: entity) else {
            return try await declaration.create()
        }
        guard !matches(published) else {
            return
        }
        try await declaration.update()
    }
}
