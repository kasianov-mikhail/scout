//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct RecordSender<T: DeliverableEntry>: Sendable {
    let id: String
    let database: any Database
}

extension RecordSender {
    init(backend: Backend) {
        id = backend.id
        database = backend.database
    }
}

package protocol TransientFailure: Error {
    var isTransient: Bool { get }
}

@MainActor extension RecordSender {
    func deliver(in context: NSManagedObjectContext) async throws {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))

        request.predicate = NSPredicate(
            format: """
                SUBQUERY(deliveries, $d, \
                $d.backendID == %@ AND $d.isPending == YES AND $d.attempts < %d\
                ).@count > 0
                """,
            id,
            DeliveryEntry.maxAttempts
        )
        request.relationshipKeyPathsForPrefetching = ["deliveries"]

        let objects = try context.fetch(request).filter {
            $0.delivery(for: id)?.isPending == true
        }

        guard objects.count > 0 else {
            return
        }

        do {
            try await send(objects)
        } catch {
            if context.hasChanges {
                try context.save()
            }
            throw error
        }

        if context.hasChanges {
            try context.save()
        }
    }

    private func send(_ objects: [T]) async throws {
        var batches = [objects]
        var probes = 32
        var rejection: (any Error)?

        while probes > 0, let batch = batches.popLast() {
            probes -= 1

            do {
                try await write(batch)
            } catch let error as CancellationError {
                throw error
            } catch let error as any TransientFailure where error.isTransient {
                throw error
            } catch {
                rejection = error
                batches += narrow(batch, after: error)
            }
        }

        if let rejection {
            throw rejection
        }
    }

    private func narrow(_ batch: [T], after error: any Error) -> [[T]] {
        guard batch.count == 1 else {
            let half = batch.count / 2
            return [Array(batch[half...]), Array(batch[..<half])]
        }

        let delivery = batch[0].delivery(for: id)
        delivery?.attempts += 1

        if let delivery, delivery.attempts >= DeliveryEntry.maxAttempts {
            print("Giving up on a \(T.self) record for backend \(id) after \(delivery.attempts) failed attempts: \(error)")
        }

        return []
    }

    private func write(_ objects: [T]) async throws {
        let records = objects.map(\.record)

        try await database.write(records: records)

        for (object, record) in zip(objects, records) where object.record == record {
            object.delivery(for: id)?.isPending = false
        }
    }
}
