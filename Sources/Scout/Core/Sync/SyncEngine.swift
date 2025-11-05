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
            try await SyncCoordinator(
                database: database,
                maxRetry: 3,
                batch: batch
            )
            .upload()

            if let objects = batch as? [CKRepresentable] {
                try await database.modifyRecords(
                    saving: objects.map(\.toRecord),
                    deleting: []
                )
            }

            for object in batch {
                object.isSynced = true
            }

            try context.save()
        }
    }
}
