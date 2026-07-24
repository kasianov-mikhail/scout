//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

final class DemoDatabase: DatabaseReader, DatabaseWriter, Sendable {
    private let records: [Record]
    private let samples: [DemoSample]
    private let activityPoints: [ActivityPoint]
    private let retentionCohorts: [RetentionCohort]

    init(corpus: DemoCorpus.Corpus) {
        self.records = corpus.records
        self.samples = corpus.samples
        self.activityPoints = corpus.activity
        self.retentionCohorts = corpus.retention
    }

    // The corpus is a fixed exhibit: host telemetry is accepted and dropped rather than mixed into the
    // lists, which would leave real records showing up next to aggregates that never move.
    func write(record: Record) async throws {}

    func write(records: [Record]) async throws {}

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let record = records.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: .max)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        var matches = records.filter {
            query.matches($0)
        }
        for sort in query.sort.reversed() {
            matches.sort { lhs, rhs in
                sort.ascending ? before(lhs, rhs, on: sort.field) : before(rhs, lhs, on: sort.field)
            }
        }
        return RecordChunk(records: Array(matches.prefix(limit)), cursor: nil)
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        samples.series(matching: query)
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activityPoints.filter { range.contains(Date(millisecondsSince1970: $0.date)) }
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        retentionCohorts.filter { range.contains($0.id) }
    }

    private func before(_ lhs: Record, _ rhs: Record, on field: String) -> Bool {
        (lhs.fields[field]?.value ?? -.greatestFiniteMagnitude)
            < (rhs.fields[field]?.value ?? -.greatestFiniteMagnitude)
    }
}
