//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Matrix {
    func lookupExisting(in database: Database) async throws -> Self? {
        let named = NSPredicate(format: "name == %@", name)
        let dated = NSPredicate(format: "date == %@", date as NSDate)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [named, dated, categoryed])

        let query = CKQuery(recordType: recordType, predicate: predicate)
        let matrices = try await database.allRecords(matching: query, desiredKeys: nil)
        let matrix = try matrices.randomElement().map(Matrix.init(record:))

        return matrix
    }

    private var categoryed: NSPredicate {
        if let category {
            NSPredicate(format: "category == %@", category)
        } else {
            NSPredicate(format: "category == nil")
        }
    }
}
