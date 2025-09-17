//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Matrix {
    func lookupExisting(in database: Database) async throws -> Self? {
        let name = NSPredicate(format: "name == %@", name)
        let date = NSPredicate(format: "date == %@", date as NSDate)
        let category = NSPredicate(format: "category == %@", category ?? NSNull())
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [name, date, category])
        let query = CKQuery(recordType: recordType, predicate: predicate)

        let matrices = try await database.allRecords(matching: query, desiredKeys: nil)
        let matrix = try matrices.randomElement().map(Matrix.init(record:))

        return matrix
    }
}
