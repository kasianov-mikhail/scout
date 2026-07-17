//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A no-op ``Database`` used as the neutral default before a backend is wired
/// in — every read returns empty and every write is discarded.
///
public struct DefaultDatabase: Database {
    public init() {}

    public func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    public func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    public func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    public func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }

    public func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        []
    }

    public func write(record: Record) async throws {}
    public func write(records: [Record]) async throws {}
}
