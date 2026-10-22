//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

@testable import NativeConnector

extension EntityStore {
    func records(entity: String, dateField: String, fields: [String], in range: Range<Date>) async throws -> [EntityRecord] {
        let ordered = query(entity)
            .filter(dateField, .greaterThanOrEquals, .date(range.lowerBound))
            .filter(dateField, .lessThan, .date(range.upperBound))
            .select(EntityCatalog.fields(entity: entity, names: fields))
            .sort(dateField, .forward)

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
