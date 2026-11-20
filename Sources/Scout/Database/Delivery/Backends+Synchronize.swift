//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@preconcurrency import CoreData

extension [Backend] {
    @MainActor
    @discardableResult
    func synchronize(using dispatcher: Dispatcher) async throws -> [String: Int] {
        let counts = Protected<[String: Int]>([:])

        try await dispatcher.performEnsuringBackground {
            try await persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.scout
                try SyncableEntry.plan(backends: self, in: context)
                try DateEntry.cleanup(backends: self, in: context)
            }

            let context = persistentContainer.newBackgroundContext()
            context.mergePolicy = NSMergePolicy.scout
            context.automaticallyMergesChangesFromParent = true

            await withTaskGroup(of: (String, Int).self) { group in
                for backend in await available(log: .console) {
                    for type in SyncableEntry.deliverableTypes {
                        group.addTask {
                            (backend.id, await backend.deliver(type, in: context, log: .console))
                        }
                    }
                    if let symbols = BundledSymbols.main {
                        group.addTask {
                            await backend.upload(symbols: symbols, defaults: .standard)
                            return (backend.id, 0)
                        }
                    }
                }

                for await (id, delivered) in group where delivered > 0 {
                    counts.mutate { $0[id, default: 0] += delivered }
                }
            }
            try Task.checkCancellation()

            try await persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy.scout
                try SyncableEntry.purge(to: Set(map(\.id)), in: context)
                try context.save()
            }
        }

        return counts.current
    }
}
