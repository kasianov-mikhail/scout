//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@MainActor
struct RecordSender {
    let id: String
    let database: any Database
    let context: NSManagedObjectContext
}

extension RecordSender {
    init(backend: Backend, context: NSManagedObjectContext) {
        self.id = backend.id
        self.database = backend.database
        self.context = context
    }
}

extension RecordSender {
    func deliver<T: Syncable & RecordEncodable>(type syncable: T.Type) async throws {
        var objects: [T] = []
        var deliveries: [SyncDelivery] = []

        for object in try syncable.pending(in: context, for: id) {
            if let delivery = object.delivery(for: id), delivery.progress.contains(.raw) {
                delivery.attempts += 1
                objects.append(object)
                deliveries.append(delivery)
            }
        }

        try context.save()

        if objects.count > 0 {
            try await database.write(records: objects.map(\.record))
            deliveries.complete(.raw)
            try context.save()
        }
    }
}
