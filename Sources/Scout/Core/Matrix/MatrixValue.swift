//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

protocol MatrixValue: Sendable {
    static var recordName: String { get }
    func toObject(in context: NSManagedObjectContext) -> MetricsObject
}

extension Int: MatrixValue {
    static let recordName = "DateIntMatrix"

    func toObject(in context: NSManagedObjectContext) -> MetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "IntMetricsObject", in: context)!
        let object = IntMetricsObject(entity: entity, insertInto: context)
        object.intValue = Int64(self)
        return object
    }
}

extension Double: MatrixValue {
    static let recordName = "DateDoubleMatrix"

    func toObject(in context: NSManagedObjectContext) -> MetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "DoubleMetricsObject", in: context)!
        let object = DoubleMetricsObject(entity: entity, insertInto: context)
        object.doubleValue = self
        return object
    }
}
