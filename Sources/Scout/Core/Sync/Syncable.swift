//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

protocol Syncable: SyncableObject {
    associatedtype Cell: CellProtocol

    static func group(in context: NSManagedObjectContext) throws -> [Self]?
    static func matrix(of batch: [Self]) throws(MatrixSyncError) -> Matrix<Cell>
    static func parse(of batch: [Self]) -> [Cell]
}

enum MatrixSyncError: LocalizedError {
    case missingProperty(String)

    var errorDescription: String? {
        switch self {
        case .missingProperty(let property):
            return "Missing property: \(property). Cannot group objects."
        }
    }
}
