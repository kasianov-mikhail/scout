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
        request.predicate = NSPredicate(
            format: "SUBQUERY(deliveries, $d, $d.backendID == %@ AND $d.isPending == YES AND $d.attempts < %d).@count > 0",
            id,
            SyncDelivery.maxAttempts
        )

        var objects: [T] = []
        var deliveries: [SyncDelivery] = []

        for object in try context.fetch(request) {
            if let delivery = object.delivery(for: id), delivery.isPending {
                objects.append(object)
                deliveries.append(delivery)
            }
        }

        if objects.count > 0 {
            try await database.write(records: objects.map(\.record))
            deliveries.forEach { $0.isPending = false }
            try context.save()
        }
    }
}
