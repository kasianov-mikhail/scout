//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct IncidentLabelLookup<Item: RecordDecodable> {
    let database: RecordReader
    let idField: String
    let labelField: String

    func labels(ids: [UUID]) async throws -> ResolvedLabels {
        try await labels(ids: ids, fields: [labelField])[labelField] ?? ResolvedLabels()
    }

    func labels(ids: [UUID], fields: [String]) async throws -> [String: ResolvedLabels] {
        let records = try await database.readAll(
            type: Item.self,
            field: idField,
            values: ids.map(\.uuidString),
            fields: [idField] + fields
        )

        var result = fields.reduce(into: [String: ResolvedLabels]()) { partial, field in
            partial[field] = ResolvedLabels()
        }

        for record in records {
            guard let id = record[idField].flatMap(UUID.init) else {
                continue
            }
            for field in fields {
                result[field]?.resolve(id: id, label: record[field])
            }
        }
        return result
    }
}
