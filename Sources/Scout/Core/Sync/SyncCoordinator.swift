//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct SyncCoordinator<T: CellProtocol>: Sendable {
    let database: Database
    let maxRetry: Int
    let matrix: Matrix<T>
}

extension SyncCoordinator {
    init<V: MatrixBatch>(database: Database, maxRetry: Int, batch: [V]) throws where V.Cell == T {
        self.database = database
        self.maxRetry = maxRetry
        self.matrix = try V.matrix(of: batch)
    }
}

extension SyncCoordinator {
    /// Merges into the bucket's existing record when one exists,
    /// otherwise creates a new one.
    ///
    func upload() async throws {
        if let existing = try await matrix.lookupExisting(in: database) {
            try await upload(snapshot: matrix + existing)
        } else {
            try await upload(snapshot: matrix)
        }
    }

    /// On a `serverRecordChanged` conflict, merges the server's counts with
    /// ours and retries; once retries run out, or no server record is
    /// provided, writes a new matrix instead.
    ///
    /// Duplicates are harmless — reads sum a bucket's records via
    /// `mergeDuplicates`.
    ///
    func upload(snapshot: Matrix<T>, retry: Int = 1) async throws {
        do {
            try await database.write(record: snapshot.toRecord)
        } catch let error as CKError where error.code == CKError.serverRecordChanged {
            if retry <= maxRetry, let serverRecord = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
                try await upload(snapshot: try Matrix(record: serverRecord) + matrix, retry: retry + 1)
            } else {
                try await upload(snapshot: matrix, retry: 1)
            }
        }
    }
}
