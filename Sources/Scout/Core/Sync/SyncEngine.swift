//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

struct SyncEngine: @unchecked Sendable {
    let database: Database
    let context: NSManagedObjectContext

    @MainActor func send<T: Syncable & MatrixBatch>(type syncable: T.Type) async throws {
        while let batch = try syncable.group(in: context) {
            try Task.checkCancellation()

            for object in batch {
                object.syncAttempts += 1
            }

            // Persist attempt counters so cleanup can retire records that keep failing.
            try context.save()

            if let objects = batch as? [CKRepresentable] {
                try await database.write(
                    records: objects.map(\.toRecord)
                )
            }

            // Records already counted into the server matrix on a previous
            // attempt must not contribute again, or the matrix double-counts.
            let pending = batch.filter { $0.syncState == .pending }

            if pending.count > 0 {
                try await SyncCoordinator(
                    database: database,
                    maxRetry: 3,
                    batch: pending
                )
                .upload()

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
}
