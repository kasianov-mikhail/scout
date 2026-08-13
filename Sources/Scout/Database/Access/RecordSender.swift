//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct RecordSender: Sendable {
    // A rejected batch names no culprit, so it is halved and resent until the
    // offending records stand alone and only they are charged. This caps the sends
    // one pass spends on that search, so a backend rejecting everything can't turn
    // a backlog into thousands of requests.
    static let maxProbes = 32

    let id: String
    let database: any Database
    let isTransientError: @Sendable (any Error) -> Bool
}

extension RecordSender {
    init(backend: Backend) {
        self.id = backend.id
        self.database = backend.database
        self.isTransientError = backend.isTransientError
    }
}

@MainActor
extension RecordSender {
    func deliver(type syncable: any (SyncableEntry & RecordEncodable).Type, in context: NSManagedObjectContext)
        async throws
    {
        try await deliver(pending: syncable, in: context)
    }

    private func deliver<T: SyncableEntry & RecordEncodable>(pending: T.Type, in context: NSManagedObjectContext)
        async throws
    {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = NSPredicate(
            format:
                "SUBQUERY(deliveries, $d, $d.backendID == %@ AND $d.isPending == YES AND $d.attempts < %d).@count > 0",
            id,
            DeliveryEntry.maxAttempts
        )

        let objects = try context.fetch(request).filter { $0.delivery(for: id)?.isPending == true }

        guard objects.count > 0 else {
            return
        }

        do {
            try await send(objects)
        } catch {
            try save(context)
            throw error
        }

        try save(context)
    }

    private func send<T: SyncableEntry & RecordEncodable>(_ objects: [T]) async throws {
        var batches = [objects]
        var probes = Self.maxProbes
        var rejection: (any Error)?

        while probes > 0, let batch = batches.popLast() {
            probes -= 1

            do {
                try await write(batch)
            } catch {
                // Only a rejection consumes the attempt budget: transient failures
                // (offline, throttling, cancellation) must not burn the queue while
                // the backend is unreachable.
                guard !(error is CancellationError), !isTransientError(error) else {
                    throw error
                }

                rejection = error

                if batch.count > 1 {
                    let half = batch.count / 2
                    batches.append(Array(batch[half...]))
                    batches.append(Array(batch[..<half]))
                } else {
                    batch[0].delivery(for: id)?.attempts += 1
                }
            }
        }

        if let rejection {
            throw rejection
        }
    }

    private func write<T: SyncableEntry & RecordEncodable>(_ objects: [T]) async throws {
        let records = objects.map(\.record)

        try await database.write(records: records)

        for (object, record) in zip(objects, records) where object.record == record {
            object.delivery(for: id)?.isPending = false
        }
    }

    private func save(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
