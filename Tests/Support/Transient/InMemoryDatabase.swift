//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

struct RejectedRecordError: Error {
    let recordID: String
}

/// A connectivity-style failure: delivery must not charge an attempt for it.
struct TransientTestError: TransientFailure {
    let isTransient = true
}

final class InMemoryDatabase: DatabaseReader, DatabaseWriter, @unchecked Sendable {
    var records: [Record] = []
    var errors: [Error] = []
    var writeErrors: [Error] = []
    var beforeWrite: (() async -> Void)?

    /// Rejects a batch carrying any matching record, the way a backend refuses a
    /// single malformed one while accepting everything sent alongside it.
    var reject: ((Record) -> Bool)?

    private(set) var writeCount = 0

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let record = records.first(where: { $0.recordID == recordName }) else {
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
        await beforeWrite?()
        writeCount += 1

        if let error = writeErrors.popLast() ?? errors.popLast() {
            throw error
        }
        if let reject, let rejected = records.first(where: reject) {
            throw RejectedRecordError(recordID: rejected.recordID)
        }

        self.records += records
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        if let error = errors.popLast() {
            throw error
        }
        return RecordChunk(
            records: records.filter { query.matches($0) },
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
}

extension InMemoryDatabase {
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        []
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }
}

extension InMemoryDatabase {
    var events: [Record] {
        records.filter { $0.recordType == EventEntry.recordType }
    }
}
