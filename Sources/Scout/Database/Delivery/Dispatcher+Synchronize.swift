//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CoreData

typealias Synchronize = @MainActor () async throws -> Void

extension Dispatcher {
    @MainActor
    func synchronize(backends: [Backend]) async throws {
        let context = persistentContainer.viewContext

        try await performEnsuringBackground {
            try await persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.scout
                try SyncableEntry.plan(backends: backends, in: context)
                try DateEntry.cleanup(backends: backends, in: context)
            }

            await withTaskGroup(of: Void.self) { group in
                for backend in await backends.available {
                    let sender = RecordSender(backend: backend)

                    for type in SyncableEntry.deliverableTypes {
                        group.addTask {
                            await sender.deliver(type, in: context)
                        }
                    }
                }
            }
            try Task.checkCancellation()

            try await persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.scout
                try SyncableEntry.purge(to: Set(backends.map(\.id)), in: context)
                try context.save()
            }
        }
    }
}
