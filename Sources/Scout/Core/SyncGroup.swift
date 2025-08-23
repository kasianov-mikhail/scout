//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

struct SyncGroup: @unchecked Sendable {
    let recordType: String
    let name: String
    let date: Date
    let objects: [Syncable]
    let fields: [String: Int]
}

extension SyncGroup {
    func newMatrix() -> CKRecord {
        let matrix = CKRecord(recordType: recordType)
        matrix["name"] = name
        matrix["date"] = date
        matrix["version"] = 1
        return matrix
    }

    func matrix(in database: Database) async throws -> CKRecord {
        let namePredicate = NSPredicate(format: "name == %@", name)
        let datePredicate = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [namePredicate, datePredicate]
        )
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let keys = fields.map { key, _ in key }
        let allMatrices = try await database.allRecords(matching: query, desiredKeys: keys)
        return allMatrices.randomElement() ?? newMatrix()
    }
}

extension SyncGroup: CustomStringConvertible {
    var description: String {
        "SyncGroup(name: \(name), date: \(date), objects: \(objects.count), fields: \(fields), recordType: \(recordType)"
    }
}
