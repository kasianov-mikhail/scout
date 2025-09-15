//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

protocol MetricsObjectProtocol {
    associatedtype Value: MatrixValue
    var value: Value { get set }
}

@objc(MetricsObject)
class MetricsObject: TrackedObject {
    static func group<T: MetricsObject & Syncable>(in context: NSManagedObjectContext) throws -> [T]? {
        try batch(in: context, matching: [\.name, \.telemetry, \.week])
    }

    static func matrix<T: MetricsObject & Syncable>(of batch: [T]) throws(MatrixSyncError) -> Matrix<T.Cell> {
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
            recordType: T.Cell.Scalar.recordName,
            date: week,
            name: name,
            category: telemetry,
            cells: T.parse(of: batch)
        )
    }

    static func parse<
        T: MetricsObject & MetricsObjectProtocol & Syncable,
        V: CellProtocol
    >(of batch: [T])  -> [V] where T.Value == V.Scalar {
        batch.grouped(by: \.hour).mapValues { items in
            items.reduce(.zero) { $0 + $1.value }
        }
        .map(V.init)
    }
}

@objc(DoubleMetricsObject)
final class DoubleMetricsObject: MetricsObject, Syncable, MetricsObjectProtocol {
    typealias Cell = GridCell<Double>
    @NSManaged var value: Double
}

@objc(IntMetricsObject)
final class IntMetricsObject: MetricsObject, Syncable, MetricsObjectProtocol {
    typealias Cell = GridCell<Int>
    @NSManaged var value: Int
}
