//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

let nativePageSize = 400

extension QueryBuilder {
    // The store bounds every read it offers, so a sweep is a walk over its
    // keyset pages: one request per page rather than one for the whole entity,
    // stopping as soon as a page runs short.
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
    func records(entity: String, dateField: String, in range: Range<Date>) async throws -> [EntityRecord] {
        try await query(entity)
            .filter(dateField, in: range)
            .records(orderedBy: dateField, ascending: true)
    }
}
