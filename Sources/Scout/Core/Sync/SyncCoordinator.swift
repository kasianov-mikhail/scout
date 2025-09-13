//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
struct SyncCoordinator<T: CellProtocol & Combining & Sendable> {
    let database: Database
    let maxRetry: Int
    let matrix: Matrix<T>

    func upload() async throws {
        let matrix = try await matrix.lookupExisting(in: database) ?? matrix
        try await upload(matrix: matrix, retry: 1)
    }

    func upload(matrix: Matrix<T>, retry: Int) async throws {
        do {
            try await database.save(matrix.toRecord)
        } catch let error as CKError where error.code == CKError.serverRecordChanged {
            if retry > maxRetry {
                try await upload(matrix: matrix, retry: 1)
            } else if let serverRecord = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
                try await upload(matrix: try Matrix(record: serverRecord) + matrix, retry: retry + 1)
            }
        }
    }
}
