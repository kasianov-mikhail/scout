//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// Maximum number of records per CloudKit modify request.
private let maxBatchSize = 400

/// Adapts a CloudKit database to the neutral record surface, mapping
/// ``Record`` and ``RecordQuery`` to and from their CloudKit forms.

// MARK: - Reading

extension CKDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: CKQueryOperation.maximumResults)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await runner { database in
            try await RecordChunk(
                results: database.records(
                    matching: CKQuery(query),
                    desiredKeys: fields,
                    resultsLimit: limit
                )
            )
        }
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        guard case .opaque(let token) = cursor, let cursor = token as? CKQueryOperation.Cursor else {
            throw CursorMismatchError()
        }
        return try await runner { database in
            try await RecordChunk(
                results: database.records(
                    continuingMatchFrom: cursor,
                    desiredKeys: fields,
                    resultsLimit: CKQueryOperation.maximumResults
                )
            )
        }
    }
}

extension RecordChunk {
    fileprivate init(results: ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)) throws {
        records = try results.0.map { try Record(ckRecord: $0.1.get()) }
        cursor = results.1.map(RecordCursor.opaque)
    }
}

// MARK: - Writing

extension CKDatabase: RecordWriter {
    func write(record: Record) async throws {
        do {
            try await runner { database in
                try await database.save(record.ckRecord)
            }
        } catch let error as CKError where error.code == .serverRecordChanged {
            guard let server = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else {
                throw error
            }
            throw RecordConflictError(serverRecord: Record(ckRecord: server))
        }
    }

    func write(records: [Record]) async throws {
        for chunk in records.chunked(into: maxBatchSize) {
            try await runner { database in
                try await database.modifyRecords(
                    saving: chunk.map(\.ckRecord),
                    deleting: [],
                    savePolicy: .allKeys,
                    atomically: true
                )
            }
        }
    }
}

// MARK: - Lookup

extension CKDatabase: RecordLookup {
    func lookup(id: RecordID, fields: [String]?) async throws -> Record {
        try await runner { database in
            let recordID = CKRecord.ID(recordName: id.recordName)
            guard let result = try await database.records(for: [recordID], desiredKeys: fields)[recordID] else {
                throw RecordNotFoundError()
            }
            return try Record(ckRecord: result.get())
        }
    }
}
