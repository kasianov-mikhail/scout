//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import CloudKit

extension MetricsObject {
    static func group<T: MetricsObject & Syncable>(
        in context: NSManagedObjectContext
    ) throws -> SyncGroup<T>? {
        guard let batch: [T] = try batch(in: context, matching: [\.name, \.telemetry, \.week]) else {
            return nil
        }
        guard let matrix = matrix(of: batch) else {
            return nil
        }
        return SyncGroup(
            matrix: matrix,
            representables: nil,
            batch: batch
        )
    }

    static func matrix<T: MetricsObject & Syncable>(of batch: [T]) -> Matrix<T.Cell>? {
        guard let name = batch.first?.name, let telemetry = batch.first?.telemetry, let week = batch.first?.week else {
            return nil
        }
        return Matrix(
            recordType: T.Cell.Scalar.recordName,
            date: week,
            name: name,
            category: telemetry,
            cells: T.parse(of: batch)
        )
    }
}
