//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package typealias Database = DatabaseReader & DatabaseWriter

package protocol DatabaseReader: Sendable {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk
    func lookup(recordName: String, fields: [String]?) async throws -> Record
    func series(matching query: SeriesQuery) async throws -> [MetricSeries]
    func activity(in range: Range<Date>) async throws -> [ActivityPoint]
    func retention(in range: Range<Date>) async throws -> [RetentionCohort]
}

package protocol DatabaseWriter: Sendable {
    func write(record: Record) async throws
    func write(records: [Record]) async throws
}

extension DatabaseReader {
    package func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await read(matching: query, fields: fields)
    }

    package func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        try await cursor.next(fields)
    }

    package func readAll(matching query: RecordQuery, fields: [String]?) async throws -> [Record] {
        var chunk = try await read(matching: query, fields: fields)
        while let cursor = chunk.cursor {
            chunk += try await readMore(from: cursor, fields: fields)
        }
        return chunk.records
    }

    package func readAll<T: RecordDecodable>(matching query: RecordQuery, fields: [String]? = nil) async throws -> [T] {
        try await readAll(matching: query, fields: fields).map(T.init)
    }
}

extension DatabaseWriter {
    // Records are written in batches no larger than this; the backends cap a single
    // save/modify request at 400 records.
    package static var maxBatchSize: Int { 400 }
}

package struct RecordNotFoundError: LocalizedError {
    package let errorDescription: String? = "No record found for the requested identifier"

    package init() {}
}
