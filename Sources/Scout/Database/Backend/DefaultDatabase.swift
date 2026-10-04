//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A no-op ``Database`` used as the neutral default before a backend is wired
/// in — every read returns empty and every write is discarded.
///
package struct DefaultDatabase: Database {
    package init() {}

    package func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    package func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    package func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    package func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }

    package func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        []
    }

    package func write(record: Record) async throws {}
    package func write(records: [Record]) async throws {}
}
