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
        let records = try await database.readAll(
            type: Item.self,
            field: idField,
            values: ids.map(\.uuidString),
            fields: [idField, labelField]
        )

        var labels = ResolvedLabels()
        for record in records {
            guard let id = record[idField].flatMap(UUID.init) else {
                continue
            }
            labels.resolve(id: id, label: record[labelField])
        }
        return labels
    }
}
