//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(MetricsObject)
class MetricsObject: TrackedObject {
    static func group<T: MetricsValued>(in context: NSManagedObjectContext) throws -> [T]? {
        try batch(in: context, matching: [\.name, \.telemetry, \.week])
    }

    static func matrix<T: MetricsValued>(of batch: [T]) throws(MatrixSyncError) -> Matrix<T.Cell> {
        guard let name = batch.first?.name else {
            throw .missingProperty("name")
        }
        guard let telemetry = batch.first?.telemetry else {
            throw .missingProperty("telemetry")
        }
        guard let week = batch.first?.week else {
            throw .missingProperty("week")
        }
        return Matrix(
            recordType: T.Value.recordName,
            date: week,
            name: name,
            category: telemetry,
            cells: T.parse(of: batch)
        )
    }

    static func parse<T: MetricsValued>(of batch: [T]) -> [T.Cell] {
        batch.grouped(by: \.hour).mapValues { items in
            items.reduce(.zero) { $0 + $1.value }
        }
        .map(T.Cell.init)
    }
}
