//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct MatrixUploader<T: CellProtocol>: Sendable {
    let database: RecordWriter & RecordReader
    let maxRetry: Int
    let matrix: Matrix<T>
}

extension MatrixUploader {
    init<V: MatrixBatch>(database: RecordWriter & RecordReader, maxRetry: Int, batch: [V]) throws where V.Cell == T {
        self.database = database
        self.maxRetry = maxRetry
        self.matrix = try V.matrix(of: batch)
    }
}

extension MatrixUploader {
    func upload() async throws {
        if let existing = try await matrix.lookupExisting(in: database) {
            try await upload(snapshot: matrix + existing)
        } else {
            try await upload(snapshot: matrix)
        }
    }

    func upload(snapshot: Matrix<T>, retry: Int = 1) async throws {
        do {
            try await database.write(record: snapshot.record)
        } catch let error as RecordConflictError {
            if retry <= maxRetry {
                try await upload(snapshot: try Matrix(record: error.serverRecord) + matrix, retry: retry + 1)
            } else {
                try await upload(snapshot: matrix, retry: 1)
            }
        }
    }
}

protocol ClientAggregating: RecordWriter, RecordReader {}

extension ClientAggregating {
    func aggregate<C: CellProtocol>(matrix: Matrix<C>) async throws {
        try await MatrixUploader(database: self, maxRetry: 3, matrix: matrix).upload()
    }
}

extension CKDatabase: ClientAggregating {}
