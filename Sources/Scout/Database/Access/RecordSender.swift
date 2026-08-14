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
}

extension RecordSender {
    init(backend: Backend) {
        self.id = backend.id
        self.database = backend.database
    }
}

package protocol TransientFailure: Error {
    var isTransient: Bool { get }
}

@MainActor extension RecordSender {
    func deliver(_ type: any (SyncableEntry & RecordEncodable).Type, in context: NSManagedObjectContext) async throws {
        try await deliver(type: type, in: context)
    }

    func deliver<T: SyncableEntry & RecordEncodable>(type: T.Type, in context: NSManagedObjectContext) async throws {
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

    private func send<T: SyncableEntry & RecordEncodable>(_ objects: [T]) async throws {
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
}
