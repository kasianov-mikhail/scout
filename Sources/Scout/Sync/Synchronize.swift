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

    try SyncableEntry.plan(backends: backends, in: context)
    try DateEntry.cleanup(backends: backends, in: context)

    try await dispatcher.performEnsuringBackground {
        // Probe every backend at once: awaiting availability in the loop
        // condition let a slow or timing-out backend stall delivery for all
        // the others queued behind it.
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
                    group.addTask { try? await recordSender.deliver(type: type, in: context) }
                }
            }
        }
        try Task.checkCancellation()
    }
}
