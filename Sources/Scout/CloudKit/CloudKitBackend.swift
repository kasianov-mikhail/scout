//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: BackendDatabase {}

/// The CloudKit container Scout traditionally syncs to.
///
/// CloudKit cannot aggregate server-side, so the client also maintains matrix
/// records. This is the one place the package holds a `CKContainer`; the host
/// constructs it and hands it over as an `any Backend`.
///
public struct CloudKitBackend: Backend {
    let container: CKContainer

    public init(container: CKContainer) {
        self.container = container
    }
}

extension CloudKitBackend: BackendResolving {
    var resolved: ResolvedBackend {
        let container = container
        return ResolvedBackend(
            id: container.containerIdentifier ?? "cloudKit",
            database: container.publicCloudDatabase,
            needsClientAggregation: true,
            acceptsRawMetrics: false,
            checkAvailability: {
                guard try await container.accountStatus() == .available else {
                    throw SyncController.NotLoggedInError()
                }
            },
            displayName: "iCloud",
            displayHost: container.containerIdentifier ?? "CloudKit",
            probeStatus: {
                let status = try? await container.accountStatus()
                return status == .available ? .reachable : .unreachable
            },
            accountWarning: {
                (try? await container.accountStatus()) != .available
            },
            verifySchema: {
                try await container.verifySchema()
            },
            onSetup: {
                verifyParallelismIfDue(container: container)
            }
        )
    }
}
