//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package typealias Database = DatabaseReader & DatabaseWriter

package typealias DatabaseReader = SeriesReader & AudienceReader & RecordReader

package protocol DatabaseWriter: Sendable {
    func write(record: Record) async throws
    func write(records: [Record]) async throws
}

package protocol SeriesReader: Sendable {
    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries]
    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries]
    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries]
}

package protocol AudienceReader: Sendable {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint]
    func retention(in range: Range<Date>) async throws -> [RetentionCohort]
}

package protocol RecordReader: Sendable {
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk
    func lookup(recordName: String, fields: [String]?) async throws -> Record
}

extension RecordReader {
    package func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: defaultRecordPageSize)
    }
}

package struct RecordNotFoundError: LocalizedError {
    package let errorDescription: String? = "No record found for the requested identifier"
    package init() {}
}
