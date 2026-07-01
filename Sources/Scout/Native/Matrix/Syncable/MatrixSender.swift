//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct MatrixSender: Sendable {
    let id: String
    let aggregator: any MatrixAggregator
}

extension MatrixSender {
    init?(backend: Backend) {
        guard let aggregator = backend.aggregator else {
            return nil
        }
        self.id = backend.id
        self.aggregator = aggregator
    }
}

@MainActor
extension MatrixSender {
    func deliver<T: Syncable & MatrixBatch>(type syncable: T.Type, in context: NSManagedObjectContext) async throws {
        while let batch = try syncable.group(in: context, for: id) {
            try Task.checkCancellation()

            var objects: [T] = []
            var deliveries: [SyncDelivery] = []

            for object in batch {
                if let delivery = object.delivery(for: id), delivery.progress.contains(.matrix) {
                    objects.append(object)
                    deliveries.append(delivery)
                }
            }

            let matrix = try T.matrix(of: objects)
            try await aggregator.aggregate(matrix: matrix)
            deliveries.complete(.matrix)

            try context.save()
        }
    }
}
