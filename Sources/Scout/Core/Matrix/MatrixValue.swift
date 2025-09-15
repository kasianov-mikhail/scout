//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import CloudKit

protocol MatrixValue: CKRecordValueProtocol & AdditiveArithmetic & Sendable & Hashable {
    associatedtype Object: MetricsObject

    static var recordName: String { get }
    func toObject(in context: NSManagedObjectContext) -> Object
}

extension Int: MatrixValue {
    static let recordName = "DateIntMatrix"

    func toObject(in context: NSManagedObjectContext) -> IntMetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "IntMetricsObject", in: context)!
        let object = IntMetricsObject(entity: entity, insertInto: context)
        object.value = self
        return object
    }
}

extension Double: MatrixValue {
    static let recordName = "DateDoubleMatrix"

    func toObject(in context: NSManagedObjectContext) -> DoubleMetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "DoubleMetricsObject", in: context)!
        let object = DoubleMetricsObject(entity: entity, insertInto: context)
        object.value = self
        return object
    }
}
