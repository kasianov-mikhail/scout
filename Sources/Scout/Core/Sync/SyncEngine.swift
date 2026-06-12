//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

struct SyncEngine: @unchecked Sendable {
    let backends: [ResolvedBackend]
    let context: NSManagedObjectContext

    init(backends: [ResolvedBackend], context: NSManagedObjectContext) {
        self.backends = backends
        self.context = context
    }

    init(database: any BackendDatabase, context: NSManagedObjectContext) {
        self.init(
            backends: [
                ResolvedBackend(
                    database: database,
                    needsClientAggregation: true,
                    acceptsRawMetrics: false,
                    checkAvailability: {}
                )
            ],
            context: context
        )
    }

    @MainActor func send<T: Syncable & MatrixBatch>(type syncable: T.Type) async throws {
        while let batch = try syncable.group(in: context) {
            try Task.checkCancellation()

            for object in batch {
                object.syncAttempts += 1
            }

            // Persist attempt counters so cleanup can retire records that keep failing.
            try context.save()

            // Raw uploads are idempotent upserts keyed by record name, so a
            // batch that failed on one backend safely re-runs on all of them.
            for backend in backends {
                if let records = records(of: batch, for: backend) {
                    try await backend.database.write(records: records)
                }
            }

            // Records already counted into the server matrix on a previous
            // attempt must not contribute again, or the matrix double-counts.
            let pending = batch.filter { $0.syncState == .pending }
            let aggregating = backends.filter(\.needsClientAggregation)

            if pending.count > 0 && !aggregating.isEmpty {
                for backend in aggregating {
                    try await SyncCoordinator(
                        database: backend.database,
                        maxRetry: 3,
                        batch: pending
                    )
                    .upload()
                }

                for object in pending {
                    object.syncState = .aggregated
                }

                // Persist right away so a crash before the final save
                // doesn't replay the matrix contribution on the next cycle.
                try context.save()
            }

            for object in batch {
                object.syncState = .synced
            }

            try context.save()
        }
    }

    /// The raw records a batch contributes to a backend, if any.
    ///
    /// Backends with native aggregation take the server representation,
    /// which exists for more types (raw metrics have no CloudKit record).
    /// Types with neither representation sync as matrices only.
    ///
    private func records(of batch: [some Syncable], for backend: ResolvedBackend) -> [CKRecord]? {
        if backend.acceptsRawMetrics, let objects = batch as? [ServerRepresentable] {
            return objects.map(\.toServerRecord)
        }
        if let objects = batch as? [CKRepresentable] {
            return objects.map(\.toRecord)
        }
        return nil
    }
}
