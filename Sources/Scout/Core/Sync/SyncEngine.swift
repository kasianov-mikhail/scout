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
                    id: "default",
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

            // Each backend is an independent destination: a failure on one
            // must not abort uploads to the others. Collect the first error
            // and surface it once the batch has done all it can this cycle.
            var firstError: Error?

            // Raw fan-out. Skip backends that already hold the record (their
            // delivery was recorded on an earlier cycle), so a healthy backend
            // is never re-written while a failing one is retried.
            for backend in backends {
                do {
                    let undelivered = batch.filter { !$0.deliveredRaw.contains(backend.id) }
                    if let records = records(of: undelivered, for: backend), records.count > 0 {
                        try await backend.database.write(records: records)
                        for object in undelivered {
                            object.markRawDelivered(to: backend.id)
                        }
                        // Persist per backend so its delivery survives a later
                        // backend failing in the same cycle.
                        try context.save()
                    }
                } catch {
                    firstError = firstError ?? error
                }
            }

            // Matrix contribution (CloudKit only). Records already counted on a
            // previous attempt carry `.aggregated`, so they don't contribute
            // again and double-count the matrix.
            let aggregating = backends.filter(\.needsClientAggregation)
            let notAggregated = batch.filter { $0.syncState == .pending }

            if notAggregated.count > 0 && !aggregating.isEmpty {
                do {
                    for backend in aggregating {
                        try await SyncCoordinator(
                            database: backend.database,
                            maxRetry: 3,
                            batch: notAggregated
                        )
                        .upload()
                    }

                    for object in notAggregated {
                        object.syncState = .aggregated
                    }

                    // Persist right away so a crash before the final save
                    // doesn't replay the matrix contribution on the next cycle.
                    try context.save()
                } catch {
                    firstError = firstError ?? error
                }
            }

            // A record is fully synced once its matrix is contributed (or no
            // backend aggregates) and its raw record has reached every backend
            // that takes one.
            let matrixDone = aggregating.isEmpty
            let rawBackends = backends.filter { records(of: batch, for: $0) != nil }
            for object in batch {
                let rawDelivered = rawBackends.allSatisfy { object.deliveredRaw.contains($0.id) }
                if rawDelivered && (matrixDone || object.syncState != .pending) {
                    object.syncState = .synced
                }
            }

            try context.save()

            // Re-fetching the same unsynced batch would spin forever, so stop
            // the cycle here; the next sync run retries only what's left.
            if let firstError {
                throw firstError
            }
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
