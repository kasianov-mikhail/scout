//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Matrix {
    func lookupExisting(in database: Database) async throws -> Self? {
        let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let matrices = try await database.fetchAll(matching: query, fields: nil)
        let matrix = try matrices.randomElement().map(Matrix.init)

        return matrix
    }

    private var predicates: [NSPredicate] {
        var predicates = [
            NSPredicate(format: "name == %@", name),
            NSPredicate(format: "date == %@", date as NSDate),
        ]
        if let category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        return predicates
    }
}
