//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct DefaultDatabase: Database {
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
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

    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        []
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        ranges.map { _ in 0 }
    }

    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        nil
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}

extension EnvironmentValues {
    @Entry var database: DatabaseReader = DefaultDatabase()
}
