//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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

            // What each backend needs for this batch: a raw upload if it takes
            // raw records for this type, plus a matrix contribution if it
            // aggregates on the client. Computed once — `records(of:for:)` is
            // uniform across a batch (it casts on the static type).
            let requirements = backends.map { (backend: $0, need: required(for: $0, in: batch)) }

            // Records left `.aggregated` by an older build already contributed
            // their matrix and, by that build's ordering, raw-uploaded to every
            // backend. Seed that progress so the new pipeline neither re-uploads
            // nor double-counts, then drop the legacy state.
            for object in batch where object.syncState == .aggregated {
                for requirement in requirements {
                    object.mark(requirement.need, for: requirement.backend.id)
                }
                object.syncState = .pending
            }

            // Each backend is an independent destination: a failure on one must
            // not abort uploads to the others. Collect the first error and
            // surface it once the batch has done all it can this cycle.
            var firstError: Error?

            for backend in backends {
                do {
                    // Raw upload. Skip records this backend already holds, so a
                    // healthy backend is never re-written while a failing one is
                    // retried. Raw writes are idempotent upserts keyed by record
                    // name, so a repeat after a partial failure is harmless.
                    let needRaw = batch.filter { !$0.progress(for: backend.id).contains(.raw) }
                    if let records = records(of: needRaw, for: backend), records.count > 0 {
                        try await backend.database.write(records: records)
                        for object in needRaw {
                            object.mark(.raw, for: backend.id)
                        }
                        // Persist per backend so its progress survives a later
                        // backend failing in the same cycle.
                        try context.save()
                    }

                    // Matrix contribution. Tracked per backend because a matrix
                    // is additive: a record already folded in must not contribute
                    // again, even if another backend's matrix failed mid-cycle.
                    if backend.needsClientAggregation {
                        let needMatrix = batch.filter { !$0.progress(for: backend.id).contains(.matrix) }
                        if needMatrix.count > 0 {
                            try await SyncCoordinator(
                                database: backend.database,
                                maxRetry: 3,
                                batch: needMatrix
                            )
                            .upload()
                            for object in needMatrix {
                                object.mark(.matrix, for: backend.id)
                            }
                            // Persist right away so a crash before the final save
                            // doesn't replay the matrix contribution next cycle.
                            try context.save()
                        }
                    }
                } catch {
                    firstError = firstError ?? error
                }
            }

            // A record is synced once every backend has everything it needs.
            for object in batch where requirements.allSatisfy({ object.progress(for: $0.backend.id).isSuperset(of: $0.need) }) {
                object.syncState = .synced
            }

            try context.save()

            // Re-fetching the same unsynced batch would spin forever, so stop
            // the cycle here; the next sync run retries only what's left.
            if let firstError {
                throw firstError
            }
        }
    }

    /// The progress a backend must reach before it's done with this batch: a
    /// raw upload when it takes raw records for this type, and a matrix
    /// contribution when it aggregates on the client.
    ///
    private func required(for backend: ResolvedBackend, in batch: [some Syncable]) -> BackendProgress {
        var need: BackendProgress = []
        if records(of: batch, for: backend) != nil {
            need.insert(.raw)
        }
        if backend.needsClientAggregation {
            need.insert(.matrix)
        }
        return need
    }

    /// The raw records a batch contributes to a backend, if any.
    ///
    /// Backends with native aggregation take the server representation,
    /// which exists for more types (raw metrics have no CloudKit record).
    /// Types with neither representation sync as matrices only.
    ///
    private func records(of batch: [some Syncable], for backend: ResolvedBackend) -> [Record]? {
        if backend.acceptsRawMetrics, let objects = batch as? [ServerRepresentable] {
            return objects.map(\.toServerRecord)
        }
        if let objects = batch as? [RecordRepresentable] {
            return objects.map(\.toRecord)
        }
        return nil
    }
}
