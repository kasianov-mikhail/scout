//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricsObject {
    static func group<T: MetricsObject & Syncable>(
        in context: NSManagedObjectContext
    ) throws -> SyncGroup<T>? {
        guard let batch: [T] = try batch(in: context, matching: [\.name, \.telemetry, \.week]) else {
            return nil
        }
        guard let name = batch.first?.name, let telemetry = batch.first?.telemetry, let week = batch.first?.week else {
            return nil
        }
        return SyncGroup(
            recordType: T.Cell.Scalar.recordName,
            name: "\(name)_\(telemetry)",
            date: week,
            representables: nil,
            batch: batch
        )
    }
}
