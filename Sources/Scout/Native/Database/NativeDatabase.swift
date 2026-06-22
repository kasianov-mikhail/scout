//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

private let maxBatchSize = 400

extension CKDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: CKQueryOperation.maximumResults)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        let results = try await runner { database in
            try await database.records(
                matching: CKQuery(query),
                desiredKeys: fields,
                resultsLimit: limit
            )
        }
        return try chunk(from: results)
    }

    private func chunk(from results: ([(CKRecord.ID, Result<CKRecord, Error>)], CKQueryOperation.Cursor?)) throws -> RecordChunk {
        let records = try results.0.map { try Record(ckRecord: $0.1.get()) }
        let cursor = results.1.map { token in
            RecordCursor { fields in
                let page = try await self.runner { database in
                    try await database.records(
                        continuingMatchFrom: token,
                        desiredKeys: fields,
                        resultsLimit: CKQueryOperation.maximumResults
                    )
                }
                return try self.chunk(from: page)
            }
        }
        return RecordChunk(records: records, cursor: cursor)
    }
}

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

extension CKDatabase: RecordLocator {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        try await runner { database in
            let recordID = CKRecord.ID(recordName: recordName)
            guard let result = try await database.records(for: [recordID], desiredKeys: fields)[recordID] else {
                throw RecordNotFoundError()
            }
            return try Record(ckRecord: result.get())
        }
    }
}
