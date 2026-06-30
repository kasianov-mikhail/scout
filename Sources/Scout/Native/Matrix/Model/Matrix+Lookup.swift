//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Matrix {
    func lookupExisting(in database: RecordReader) async throws -> Self? {
        let query = RecordQuery(recordType: Self.self, filters: filters)
        let matrices: [Self] = try await database.readAll(matching: query)
        return matrices.randomElement()
    }

    private var filters: [RecordQuery.Filter] {
        var filters = [
            RecordQuery.Filter(field: "name", op: .equals, value: .string(name)),
            RecordQuery.Filter(field: "date", op: .equals, value: .date(date)),
        ]
        if let category {
            filters.append(RecordQuery.Filter(field: "category", op: .equals, value: .string(category)))
        }
        if let version {
            filters.append(RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version)))
        }
        return filters
    }
}
