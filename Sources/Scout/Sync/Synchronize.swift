//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CoreData

typealias Synchronize = @MainActor () async throws -> Void

@MainActor
func synchronize(backends: [Backend], dispatcher: Dispatcher) async throws -> Void {
    let context = persistentContainer.viewContext

    try await dispatcher.performEnsuringBackground {
        try await persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.scout
            try SyncableEntry.plan(backends: backends, in: context)
            try DateEntry.cleanup(backends: backends, in: context)
        }

        let availability = await withTaskGroup(of: (Int, Bool).self) { group in
            for (offset, backend) in backends.enumerated() {
                group.addTask { (offset, await backend.checkAvailability()) }
            }
            var flags = [Bool](repeating: false, count: backends.count)
            for await (offset, isAvailable) in group {
                flags[offset] = isAvailable
            }
            return flags
        }

        await withTaskGroup(of: Void.self) { group in
            for (backend, isAvailable) in zip(backends, availability) where isAvailable {
                let recordSender = RecordSender(backend: backend)

                for type in SyncableEntry.deliverableTypes {
                    group.addTask {
                        do {
                            try await recordSender.deliver(type, in: context)
                        } catch is CancellationError {
                            // A cancelled pass leaves the records pending for the next one.
                        } catch let error as any TransientFailure where error.isTransient {
                            // Offline or throttled: the next pass retries the same records.
                        } catch {
                            print("Failed to deliver \(type) to backend \(recordSender.id): \(error)")
                        }
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
