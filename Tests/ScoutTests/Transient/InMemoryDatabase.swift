//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

final class InMemoryDatabase: DatabaseReader, RecordWriter, @unchecked Sendable {
    var records: [Record] = []
    var errors: [Error] = []
    var writeErrors: [Error] = []

    func lookup(id: RecordID, fields: [String]?) async throws -> Record {
        guard let record = records.first(where: { $0.id == id }) else {
            throw RecordNotFoundError()
        }
        return record
    }

    func write(record: Record) async throws {
        if let error = writeErrors.popLast() ?? errors.popLast() {
            throw error
        } else {
            records.append(record)
        }
    }

    func write(records: [Record]) async throws {
        if let error = writeErrors.popLast() ?? errors.popLast() {
            throw error
        } else {
            self.records += records
        }
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        if let error = errors.popLast() {
            throw error
        }
        return RecordChunk(
            records: records.filter { $0.matches(query) },
            cursor: nil
        )
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        if let error = errors.popLast() {
            throw error
        }
        return RecordChunk(
            records: [],
            cursor: nil
        )
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        try await reconstructedActivity(in: range)
    }

    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
        try await reconstructedMetricSeries(category: category, values: values, in: range)
    }
}

extension InMemoryDatabase: ClientAggregating {}

extension InMemoryDatabase {
    var events: [Record] {
        records.filter { $0.recordType == EventObject.recordType }
    }
}
