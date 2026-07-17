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
        await withTaskGroup(of: Void.self) { group in
            for backend in backends where await backend.checkAvailability() {
                await DeliveryEntry.recordAttempt(for: backend.id, in: context)

                let recordSender = RecordSender(backend: backend)

                for type in SyncableEntry.deliverableTypes {
                    group.addTask { try? await recordSender.deliver(type: type, in: context) }
                }
            }
        }
        try Task.checkCancellation()
    }
}
