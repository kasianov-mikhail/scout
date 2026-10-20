//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct RecordSender<T: DeliverableEntry>: Sendable {
    let id: String
    let database: any DatabaseWriter
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

private struct Outcome {
    var delivered: [Int] = []
    var rejected: [Int: any Error] = [:]
    var error: (any Error)?
}

extension RecordSender {
    func deliver(in context: NSManagedObjectContext) async throws {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self), pendingBackendID: id)
        var count = DeliveryEntry.pageSize

        while count == DeliveryEntry.pageSize {
            let objects = try await context.perform {
                try context.fetch(request).filter {
                    $0.delivery(for: id)?.isPending == true
                }
            }

            guard !objects.isEmpty else { return }

            let records = await context.perform {
                objects.map(\.record)
            }
            let outcome = await send(records)

            try await context.perform {
                for index in outcome.delivered where objects[index].record == records[index] {
                    objects[index].delivery(for: id)?.isPending = false
                }
                for (index, error) in outcome.rejected {
                    guard let delivery = objects[index].delivery(for: id) else {
                        continue
                    }
                    delivery.attempts += 1

                    if delivery.attempts >= DeliveryEntry.maxAttempts {
                        print("Giving up on a \(T.self) record for backend \(id) after \(delivery.attempts) failed attempts: \(error)")
                    }
                }
                if context.hasChanges {
                    try context.save()
                }
                if let error = outcome.error {
                    throw error
                }
            }

            count = objects.count
        }
    }

    private func send(_ records: [Record]) async -> Outcome {
        var outcome = Outcome()
        var batches = [records[...]]
        var probes = 32

        while probes > 0, let batch = batches.popLast() {
            probes -= 1

            do {
                try await database.write(records: Array(batch))
                outcome.delivered += batch.indices
            } catch {
                outcome.error = error

                if error is CancellationError || (error as? any TransientFailure)?.isTransient == true {
                    return outcome
                }
                if batch.count == 1 {
                    outcome.rejected[batch.startIndex] = error
                } else {
                    let half = batch.startIndex + batch.count / 2
                    batches += [batch[half...], batch[..<half]]
                }
            }
        }

        return outcome
    }
}
