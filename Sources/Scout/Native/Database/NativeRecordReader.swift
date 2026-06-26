//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: CKQueryOperation.maximumResults)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        let results = try await runner { database in
            try await database.records(
                matching: CKQuery(query),
                desiredKeys: fields,
                resultsLimit: limit
            )
        }
        return try chunk(from: results)
    }

    private func chunk(from results: ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)) throws -> RecordChunk {
        let records = try results.0.map { try Record(ckRecord: $0.1.get()) }
        let cursor = results.1.map { token in
            RecordCursor { fields in
                let page = try await self.runner { database in
                    try await database.records(
                        continuingMatchFrom: token,
                        desiredKeys: fields,
                        resultsLimit: CKQueryOperation.maximumResults
                    )
                }
                return try self.chunk(from: page)
            }
        }
        return RecordChunk(records: records, cursor: cursor)
    }
}
