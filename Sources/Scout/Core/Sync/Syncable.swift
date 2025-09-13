//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

typealias SyncValue = MatrixValue & CKRecordValueProtocol & AdditiveArithmetic & Sendable & Hashable

protocol Syncable: NSManagedObject {
    associatedtype Cell: CellProtocol & Combining & Sendable

    static func group(in context: NSManagedObjectContext) throws -> SyncGroup<Self>?
    static func parse(of batch: [Self]) -> [Cell]

    var isSynced: Bool { get set }
}

enum SyncableError: Error {
    case missingProperty(String)

    var localizedDescription: String {
        switch self {
        case let .missingProperty(property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}
