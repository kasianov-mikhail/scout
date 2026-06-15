//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Default page size for a paginated read, matching CloudKit's modify/query
/// cap and the Scout server's own limit.
///
let defaultRecordPageSize = 400

protocol RecordReader: Sendable {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk
    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk
}

extension RecordReader {
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await read(matching: query, fields: fields)
    }

    func readAll(matching query: RecordQuery, fields: [String]?) async throws -> [Record] {
        var chunk = try await read(matching: query, fields: fields)
        while let cursor = chunk.cursor {
            chunk += try await readMore(from: cursor, fields: fields)
        }
        return chunk.records
    }
}
