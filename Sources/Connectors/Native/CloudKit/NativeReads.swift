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
}

extension QueryBuilder {
    fileprivate func select(entity: String, fields: [String]?) -> QueryBuilder {
        guard let fields else { return self }
        return select(EntityCatalog.fields(entity: entity, names: fields))
    }

    fileprivate func filter(_ filter: RecordQuery.Filter) -> QueryBuilder {
        self.filter(filter.field, filter.storeMatch, filter.value.storeValue)
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
