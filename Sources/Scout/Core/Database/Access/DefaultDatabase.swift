//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension EnvironmentValues {
    @Entry var database: DatabaseReader = DefaultDatabase()
}

struct DefaultDatabase: Database {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}
