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

extension Backend {
    /// A CloudKit backend that stores records through scout-db's frozen Entity/Vector
    /// schema.
    ///
    /// Raw records are delivered to every entity; chart aggregates are maintained by
    /// scout-db vectors on write, so no client-side matrix upload happens.
    ///
    /// - Throws: An error when the container carries no identifier, which is
    ///   what a default container resolves to in an app without an iCloud
    ///   container entitlement.
    ///
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
                    nil
                case .noAccount:
                    .noAccount
                case .restricted:
                    .restricted
                case .temporarilyUnavailable:
                    .temporarilyUnavailable
                case .couldNotDetermine:
                    .couldNotDetermine
                @unknown default:
                    .couldNotDetermine
                }
            },
            isTransientError: { error in
                (error as? CKError)?.isTransient == true
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

extension CKError {
    var isTransient: Bool {
        switch code {
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited, .zoneBusy,
            .accountTemporarilyUnavailable, .operationCancelled:
            true
        default:
            retryAfterSeconds != nil
        }
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
