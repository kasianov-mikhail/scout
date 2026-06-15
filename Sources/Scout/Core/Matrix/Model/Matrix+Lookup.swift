//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Matrix {
    func lookupExisting(in database: RecordReader) async throws -> Self? {
        let query = RecordQuery(recordType: recordType, filters: filters)
        let matrices = try await database.readAll(matching: query, fields: nil)
        let matrix = try matrices.randomElement().map(Matrix.init)

        return matrix
    }

    private var filters: [RecordFilter] {
        var filters = [
            RecordFilter(field: "name", op: .equals, value: .string(name)),
            RecordFilter(field: "date", op: .equals, value: .date(date)),
        ]
        if let category {
            filters.append(RecordFilter(field: "category", op: .equals, value: .string(category)))
        }
        return filters
    }
}
