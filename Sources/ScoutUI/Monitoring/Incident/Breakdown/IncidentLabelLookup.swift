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

    func labels(ids: [UUID]) async throws -> [UUID: String] {
        let records = try await database.readAll(
            type: Item.self,
            field: idField,
            values: ids.map(\.uuidString),
            fields: [idField, labelField]
        )

        let pairs = records.compactMap { (record: Record) -> (UUID, String)? in
            guard let id = record[idField].flatMap(UUID.init) else {
                return nil
            }
            guard let label: String = record[labelField] else {
                return nil
            }
            return (id, label)
        }

        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
