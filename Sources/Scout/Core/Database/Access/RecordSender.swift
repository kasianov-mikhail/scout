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

@MainActor
extension RecordSender {
    func deliver<T: SyncableObject & RecordEncodable>(type syncable: T.Type, in context: NSManagedObjectContext) async throws {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = NSPredicate(.raw, to: id)

        var objects: [T] = []
        var deliveries: [SyncDelivery] = []

        for object in try context.fetch(request) {
            if let delivery = object.delivery(for: id), delivery.progress.contains(.raw) {
                objects.append(object)
                deliveries.append(delivery)
            }
        }

        if objects.count > 0 {
            try await database.write(records: objects.map(\.record))
            deliveries.complete(.raw)
            try context.save()
        }
    }
}

extension NSPredicate {
    fileprivate convenience init(_ progress: SyncDelivery.Progress, to backendID: String) {
        self.init(
            format: "SUBQUERY(deliveries, $d, $d.backendID == %@ AND $d.progressPrimitive IN %@ AND $d.attempts < %d).@count > 0",
            backendID,
            progress.owingStates,
            SyncDelivery.maxAttempts
        )
    }
}

extension SyncDelivery.Progress {
    // Matches every persisted state still owing this progress, including rows the
    // legacy matrix channel wrote as [.raw, .matrix] before that channel was removed.
    fileprivate var owingStates: [Int16] {
        (0...Self.all.rawValue)
            .filter { Self(rawValue: $0).contains(self) }
            .map { Int16($0) }
    }
}
