//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: defaultRecordPageSize)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await run(query: HTTPQuery(query: query, fields: fields, limit: limit))
    }

    private func run(query: HTTPQuery) async throws -> RecordChunk {
        let response = try await send(query, to: "api/v1/records/query", into: HTTPQueryResponse.self)
        return RecordChunk(
            records: response.records.map { $0.toRecord() },
            cursor: response.cursor.map { token in
                RecordCursor { _ in
                    var next = HTTPQuery()
                    next.cursor = token
                    return try await self.run(query: next)
                }
            }
        )
    }
}
