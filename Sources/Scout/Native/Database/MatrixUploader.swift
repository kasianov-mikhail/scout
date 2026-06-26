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
