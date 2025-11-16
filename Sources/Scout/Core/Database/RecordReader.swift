//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol RecordReader {
    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk
    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk
}

extension RecordReader {
    func readAll(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> [CKRecord] {
        var chunk = try await read(matching: query, fields: fields)
        while let cursor = chunk.cursor {
            chunk += try await readMore(from: cursor, fields: fields)
        }
        return chunk.records
    }
}

extension CKDatabase: RecordReader {
    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        try await runner { database in
            try await RecordChunk(
                results: database.records(
                    matching: query,
                    desiredKeys: fields,
                    resultsLimit: CKQueryOperation.maximumResults
                )
            )
        }
    }

    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        try await runner { database in
            try await RecordChunk(
                results: database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: fields,
                    resultsLimit: CKQueryOperation.maximumResults
                )
            )
        }
    }
}
