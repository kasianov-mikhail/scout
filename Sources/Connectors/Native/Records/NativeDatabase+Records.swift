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
        let store = try await resolve()

        guard let uuids = query.uuids else {
            return try await store.page(matching: query, fields: fields, limit: limit, after: nil)
        }
        let records = try await store.fetch(entity: query.recordType.recordType, uuids: uuids)
        return RecordChunk(records: records.map(Record.init(entityRecord:)), cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let entityRecord = try await resolve().fetch(uuid: recordName) else {
            throw RecordNotFoundError()
        }
        return Record(entityRecord: entityRecord)
    }
}

extension RecordQuery {
    fileprivate var uuids: [String]? {
        guard filters.count == 1, let filter = filters.first else {
            return nil
        }
        guard filter.field == "uuid", filter.op == .in, case .strings(let uuids) = filter.value else {
            return nil
        }
        return uuids
    }
}
