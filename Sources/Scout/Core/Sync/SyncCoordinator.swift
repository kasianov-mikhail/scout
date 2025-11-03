//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor struct SyncCoordinator<T: CellProtocol> {
    let database: Database
    let maxRetry: Int
    let matrix: Matrix<T>
}

extension SyncCoordinator {
    init<V: MatrixBatch>(database: Database, maxRetry: Int, batch: [V]) throws where V.Cell == T {
        self.database = database
        self.maxRetry = maxRetry
        self.matrix = try Matrix(of: batch)
    }
}

extension SyncCoordinator {
    func upload() async throws {
        if let existing = try await matrix.lookupExisting(in: database) {
            try await upload(snapshot: matrix + existing)
        } else {
            try await upload(snapshot: matrix)
        }
    }

    func upload(snapshot: Matrix<T>, retry: Int = 1) async throws {
        do {
            try await database.save(snapshot.toRecord)
        } catch let error as CKError where error.code == CKError.serverRecordChanged {
            if retry > maxRetry {
                try await upload(snapshot: matrix, retry: 1)
            } else if let serverRecord = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
                try await upload(snapshot: try Matrix(record: serverRecord) + matrix, retry: retry + 1)
            }
        }
    }
}
