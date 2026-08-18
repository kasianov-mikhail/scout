//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

let nativePageSize = 400

extension QueryBuilder {
    func records(orderedBy field: String, ascending: Bool) async throws -> [EntityRecord] {
        let ordered = sort(field, ascending ? .forward : .reverse)

        var records: [EntityRecord] = []
        var cursor: FieldCursor?

        repeat {
            let page = try await ordered.page(size: nativePageSize, after: cursor)
            records += page.records
            cursor = page.cursor
        } while cursor != nil

        return records
    }
}

extension EntityStore {
    func page(entity: String, filters: [RecordQuery.Filter], field: String, ascending: Bool, limit: Int, after cursor: FieldCursor?) async throws -> RecordChunk {
        let page = try await filters.reduce(query(entity)) { $0.filter($1) }
            .sort(field, ascending ? .forward : .reverse)
            .page(size: limit, after: cursor)

        return RecordChunk(
            records: page.records.map(Record.init(entityRecord:)),
            cursor: page.cursor.map { next in
                RecordCursor { _ in
                    try await self.page(
                        entity: entity,
                        filters: filters,
                        field: field,
                        ascending: ascending,
                        limit: limit,
                        after: next
                    )
                }
            }
        )
    }

    func records(entity: String, dateField: String, in range: Range<Date>) async throws -> [EntityRecord] {
        try await query(entity)
            .filter(dateField, in: range)
            .records(orderedBy: dateField, ascending: true)
    }

    func visits(entity: String, dateField: String, in window: Range<Date>) async throws -> [ActivityVisit] {
        try await datedIDs(
            entity: entity,
            dateField: dateField,
            idField: "device_id",
            in: window
        )
        .map {
            ActivityVisit(date: $0.date, user: $0.id)
        }
    }

    func datedIDs(entity: String, dateField: String, idField: String, in range: Range<Date>) async throws -> [(date: Date, id: String)] {
        let records = try await records(
            entity: entity,
            dateField: dateField,
            in: range
        )

        return records.compactMap { record -> (date: Date, id: String)? in
            guard case .date(let date)? = record.values[dateField] else {
                return nil
            }
            guard case .string(let id)? = record.values[idField] else {
                return nil
            }
            return (date, id)
        }
    }
}
