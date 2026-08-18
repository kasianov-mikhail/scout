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
        page(matching: query, limit: limit, after: 0)
    }

    private func page(matching query: RecordQuery, limit: Int, after offset: Int) -> RecordChunk {
        let matches = records.filter { query.matches($0) }.sorted(by: query.ordering)
        let page = matches.dropFirst(offset).prefix(limit)
        let next = offset + page.count

        return RecordChunk(
            records: Array(page),
            cursor: next < matches.count
                ? RecordCursor { _ in self.page(matching: query, limit: limit, after: next) }
                : nil
        )
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
}

extension RecordQuery {
    fileprivate var ordering: (Record, Record) -> Bool {
        { lhs, rhs in
            for key in sort {
                let order = RecordValue.compare(lhs.fields[key.field], rhs.fields[key.field])
                guard order != .orderedSame else {
                    continue
                }
                return key.ascending ? order == .orderedAscending : order == .orderedDescending
            }
            return false
        }
    }
}

extension RecordValue {
    fileprivate static func compare(_ lhs: RecordValue?, _ rhs: RecordValue?) -> ComparisonResult {
        switch (lhs, rhs) {
        case (nil, nil):
            return .orderedSame
        case (nil, _):
            return .orderedAscending
        case (_, nil):
            return .orderedDescending
        case (.string(let lhs), .string(let rhs)):
            return lhs < rhs ? .orderedAscending : lhs == rhs ? .orderedSame : .orderedDescending
        case (let lhs?, let rhs?):
            guard let lhs = lhs.value, let rhs = rhs.value else {
                return .orderedSame
            }
            return lhs < rhs ? .orderedAscending : lhs == rhs ? .orderedSame : .orderedDescending
        }
    }
}
