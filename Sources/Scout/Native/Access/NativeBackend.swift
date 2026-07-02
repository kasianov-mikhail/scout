//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Backend {
    public static func cloudKit(container: CKContainer) -> Backend {
        Backend(
            id: container.containerIdentifier ?? "cloudKit",
            database: container.publicCloudDatabase,
            checkAvailability: {
                (try? await container.accountStatus()) == .available
            },
            displayName: "iCloud",
            aggregator: container.publicCloudDatabase,
            probeStatus: {
                let status = try? await container.accountStatus()
                return status == .available ? .reachable : .unreachable
            },
            accountWarning: {
                (try? await container.accountStatus()) != .available
            },
            verifySchema: container.verifySchema,
            schemaChecks: container.schemaChecks,
            runBenchmark: { await verifyParallelismBenchmark(container: container) },
            onSetup: container.verifyParallelismIfDue
        )
    }
}
