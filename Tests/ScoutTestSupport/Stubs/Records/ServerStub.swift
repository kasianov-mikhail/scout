//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import ScoutCore

// A `DatabaseReader` standing in for a Scout server backend: it returns the
// activity, retention, and metric series it is seeded with, and empty results
// for every other query.
final class ServerStub: DatabaseReader, @unchecked Sendable {
    let activitySeries: [ActivityPoint]
    let retentionCohorts: [RetentionCohort]
    let metricsSeries: [MetricSeries]

    init(activity: [ActivityPoint] = [], retention: [RetentionCohort] = [], metrics: [MetricSeries] = []) {
        self.activitySeries = activity
        self.retentionCohorts = retention
        self.metricsSeries = metrics
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activitySeries
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        retentionCohorts
    }

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        metricsSeries
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}
