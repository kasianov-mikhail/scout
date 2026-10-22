//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

private let flushDelay: Duration = .seconds(1)

struct PendingWrites: Sendable {
    typealias Write = @Sendable (NSManagedObjectContext) throws -> Void

    private(set) var writes: [Write] = []
    private var isScheduled = false

    mutating func append(write: @escaping Write) -> Bool {
        defer { isScheduled = true }
        writes.append(write)
        return !isScheduled
    }

    mutating func drain() -> [Write] {
        defer { self = PendingWrites() }
        return writes
    }
}

extension Runtime {
    func enqueue(urgent: Bool, write: @escaping PendingWrites.Write) {
        var isFirst = false
        pendingWrites.mutate { isFirst = $0.append(write: write) }

        guard urgent || isFirst else {
            return
        }

        Task {
            if !urgent {
                try? await Task.sleep(for: flushDelay)
            }

            let writes = drainPendingWrites()

            guard !writes.isEmpty else { return }

            do {
                try await persistentContainer.save(writes: writes)
                try await backends.synchronize(using: dispatcher)
            } catch {
                print("Failed to save logs and metrics: \(error)")
            }
        }
    }

    func drainPendingWrites() -> [PendingWrites.Write] {
        var writes: [PendingWrites.Write] = []
        pendingWrites.mutate { writes = $0.drain() }
        return writes
    }
}

extension NSPersistentContainer {
    func save(writes: [PendingWrites.Write]) async throws {
        try await performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.scout

            for write in writes {
                try write(context)
            }

            try context.save()
        }
    }
}
