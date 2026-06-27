//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

// A `DatabaseReader` standing in for a Scout server backend: it returns the
// activity and metric series it is seeded with, and empty results for every
// other query.
final class ServerStub: DatabaseReader, @unchecked Sendable {
    let activitySeries: [ActivityPoint]
    let metricsSeries: [MetricSeries]

    init(activity: [ActivityPoint] = [], metrics: [MetricSeries] = []) {
        self.activitySeries = activity
        self.metricsSeries = metrics
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activitySeries
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        metricsSeries
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }
}
