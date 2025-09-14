//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

typealias SyncValue = MatrixValue & CKRecordValueProtocol & AdditiveArithmetic & Sendable & Hashable

protocol Syncable: SyncableObject {
    associatedtype Cell: CellProtocol & Combining & Sendable

    static func group(in context: NSManagedObjectContext) throws -> [Self]?
    static func matrix(of batch: [Self]) throws(SyncableError) -> Matrix<Cell>
    static func parse(of batch: [Self]) -> [Cell]
}

enum SyncableError: LocalizedError {
    case missingProperty(String)

    var errorDescription: String? {
        switch self {
        case let .missingProperty(property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}
