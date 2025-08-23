//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor struct SyncCoordinator {
    let database: Database
    let maxRetry: Int
    let group: SyncGroup
}

extension SyncCoordinator {
    func upload() async throws {
        let matrix = try await group.matrix(in: database)

        try await upload(matrix: matrix)
    }

    fileprivate func upload(matrix: CKRecord) async throws {
        try await upload(matrix: matrix, retry: 1)
    }

    fileprivate func upload(matrix: CKRecord, retry: Int) async throws {
        matrix.merge(with: group.fields)

        do {
            try await database.save(matrix)
        } catch let error as CKError where error.code == CKError.serverRecordChanged {
            if retry > maxRetry {
                try await upload(matrix: group.newMatrix())
            } else if let serverMatrix = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
                try await upload(matrix: serverMatrix, retry: retry + 1)
            }
        }
    }
}

extension CKRecord {
    func merge(with fields: [String: Int]) {
        for (field, count) in fields {
            let oldCount: Int = self[field] ?? 0
            self[field] = oldCount + count
        }
    }
}
