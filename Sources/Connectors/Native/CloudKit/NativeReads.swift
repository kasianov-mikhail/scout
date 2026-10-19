//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

extension QueryBuilder {
    func records(orderedBy field: String, ascending: Bool) async throws -> [EntityRecord] {
        let ordered = sort(field, ascending ? .forward : .reverse)

        var records: [EntityRecord] = []
        var cursor: FieldCursor?

        repeat {
            let page = try await ordered.page(size: defaultRecordPageSize, after: cursor)
            records += page.records
            cursor = page.cursor
        } while cursor != nil

        return records
    }
}

extension EntityStore {
    func page(matching query: RecordQuery, fields: [String]?, limit: Int, after cursor: FieldCursor?) async throws -> RecordChunk {
        let sort = query.primarySort
        let entity = query.recordType.recordType

        let page = try await query.filters.reduce(self.query(entity)) { $0.filter($1) }
            .sort(sort.field, sort.ascending ? .forward : .reverse)
            .select(entity: entity, fields: fields)
            .page(size: limit, after: cursor)

        return RecordChunk(
            records: page.records.map(Record.init(entityRecord:)),
            cursor: page.cursor.map { next in
                RecordCursor { _ in
                    try await self.page(matching: query, fields: fields, limit: limit, after: next)
                }
            }
        )
    }

    func records(entity: String, dateField: String, name: String?, fields: [String], in range: Range<Date>) async throws -> [EntityRecord] {
        try await query(entity)
            .named(name)
            .filter(dateField, in: range)
            .select(entity: entity, fields: fields)
            .records(orderedBy: dateField, ascending: true)
    }

    func datedIDs(entity: String, dateField: String, idField: String, in range: Range<Date>) async throws -> [DatedID] {
        let records = try await records(
            entity: entity,
            dateField: dateField,
            name: nil,
            fields: [dateField, idField],
            in: range
        )

        return records.compactMap { record -> DatedID? in
            let date: Date? = record[dateField]
            let id: String? = record[idField]
            guard let date, let id else {
                return nil
            }
            return DatedID(date: date, id: id)
        }
    }
}

extension QueryBuilder {
    fileprivate func named(_ name: String?) -> QueryBuilder {
        guard let name else { return self }
        return filter("name", .equals, .string(name))
    }

    fileprivate func select(entity: String, fields: [String]?) -> QueryBuilder {
        guard let fields else { return self }
        return select(EntityCatalog.fields(entity: entity, names: fields))
    }

    fileprivate func filter(_ filter: RecordQuery.Filter) -> QueryBuilder {
        self.filter(filter.field, filter.storeMatch, filter.value.storeValue)
    }

    fileprivate func filter(_ field: String, in range: Range<Date>) -> QueryBuilder {
        filter(field, .greaterThanOrEquals, .date(range.lowerBound))
            .filter(field, .lessThan, .date(range.upperBound))
    }
}

extension RecordQuery.Filter {
    fileprivate var storeMatch: ScoutDB.Operator {
        switch op {
        case .equals:
            .equals
        case .notEquals:
            .notEquals
        case .greaterThan:
            .greaterThan
        case .greaterThanOrEquals:
            .greaterThanOrEquals
        case .lessThan:
            .lessThan
        case .lessThanOrEquals:
            .lessThanOrEquals
        case .in:
            .in
        case .beginsWith:
            .beginsWith
        }
    }
}
