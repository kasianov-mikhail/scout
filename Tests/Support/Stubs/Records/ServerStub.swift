//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

// A `DatabaseReader` standing in for a Scout server backend: it returns the
// activity, retention, and metric series it is seeded with, narrows the metric
// series to the queried name and category the way the server does, and returns
// empty results for every other query.
final class ServerStub: DatabaseReader, @unchecked Sendable {
    let activitySeries: [ActivityPoint]
    let retentionCohorts: [RetentionCohort]
    let metricsSeries: [MetricSeries]

    init(activity: [ActivityPoint] = [], retention: [RetentionCohort] = [], metrics: [MetricSeries] = []) {
        activitySeries = activity
        retentionCohorts = retention
        metricsSeries = metrics
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activitySeries
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        retentionCohorts
    }

    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        []
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        ranges.map { _ in 0 }
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        metricsSeries
            .filter { query.name == nil || $0.name == query.name }
            .filter { query.category == nil || $0.category == query.category }
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}
