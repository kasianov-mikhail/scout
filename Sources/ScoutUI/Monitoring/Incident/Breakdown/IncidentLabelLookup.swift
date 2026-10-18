//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

private let membershipLimit = 250

struct IncidentLabelLookup<Item: RecordDecodable> {
    let database: RecordReader
    let idField: String
    let labelField: String

    func labels(ids: [UUID]) async throws -> [UUID: String] {
        let pairs = try await records(ids: ids).compactMap { (record: Record) -> (UUID, String)? in
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

    private func records(ids: [UUID]) async throws -> [Record] {
        let values = ids.map(\.uuidString)
        let fields = [idField, labelField]

        return try await withThrowingTaskGroup(of: [Record].self) { group in
            for start in stride(from: 0, to: values.count, by: membershipLimit) {
                let query = RecordQuery(
                    recordType: Item.self,
                    filters: [
                        RecordQuery.Filter(
                            field: idField,
                            op: .in,
                            value: .strings(Array(values[start..<min(start + membershipLimit, values.count)]))
                        )
                    ]
                )
                group.addTask {
                    try await database.readAll(matching: query, fields: fields)
                }
            }

            var records: [Record] = []
            for try await chunk in group {
                records += chunk
            }
            return records
        }
    }
}
