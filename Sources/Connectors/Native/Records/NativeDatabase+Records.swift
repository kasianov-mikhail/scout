//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension NativeDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        let entity = query.recordType.recordType
        let sort = query.primarySort

        return try await resolve().page(
            entity: entity,
            filters: query.filters,
            field: sort.field,
            ascending: sort.ascending,
            limit: limit,
            after: nil
        )
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let entityRecord = try await resolve().fetch(uuid: recordName) else {
            throw RecordNotFoundError()
        }
        return Record(entityRecord: entityRecord)
    }
}
