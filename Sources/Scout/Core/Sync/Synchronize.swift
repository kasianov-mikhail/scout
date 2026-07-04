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

    try SyncableObject.plan(backends: backends, in: context)
    try SyncableObject.cleanup(backends: backends, in: context)

    try await dispatcher.performEnsuringBackground {
        await withTaskGroup(of: Void.self) { group in
            for backend in backends where await backend.checkAvailability() {
                await SyncDelivery.recordAttempt(for: backend.id, in: context)

                let recordSender = RecordSender(backend: backend)

                func deliver<T: SyncableObject & RecordEncodable>(_ type: T.Type) {
                    group.addTask { try? await recordSender.deliver(type: type, in: context) }
                }

                deliver(EventObject.self)
                deliver(SessionObject.self)
                deliver(LaunchObject.self)
                deliver(VersionObject.self)
                deliver(InstallObject.self)
                deliver(DeviceObject.self)
                deliver(CrashObject.self)
                deliver(IntMetricsObject.self)
                deliver(DoubleMetricsObject.self)
            }
        }
        try Task.checkCancellation()
    }
}
