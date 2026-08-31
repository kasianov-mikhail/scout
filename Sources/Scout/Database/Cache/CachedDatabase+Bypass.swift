//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension CachedDatabase {
    package func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await base.read(matching: query, fields: fields)
    }

    package func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await base.read(matching: query, fields: fields, limit: limit)
    }

    package func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        try await base.activity(in: range)
    }

    package func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        try await base.retention(in: range)
    }

    package func write(record: Record) async throws {
        try await base.write(record: record)
    }

    package func write(records: [Record]) async throws {
        try await base.write(records: records)
    }
}
