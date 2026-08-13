//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct RecordSender: Sendable {
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

        var objects: [T] = []
        var deliveries: [DeliveryEntry] = []

        for object in try context.fetch(request) {
            if let delivery = object.delivery(for: id), delivery.isPending {
                objects.append(object)
                deliveries.append(delivery)
            }
        }

        guard objects.count > 0 else {
            return
        }

        let records = objects.map(\.record)

        do {
            try await database.write(records: records)
            for (index, delivery) in deliveries.enumerated() where objects[index].record == records[index] {
                delivery.isPending = false
            }
        } catch {
            // Only a rejection consumes the attempt budget: transient failures
            // (offline, throttling, cancellation) must not burn the queue while
            // the backend is unreachable.
            if !(error is CancellationError) && !isTransientError(error) {
                deliveries.forEach { $0.attempts += 1 }
                try context.save()
            }
            throw error
        }

        try context.save()
    }
}
