//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A coordinator responsible for synchronizing data with a remote source.
///
/// The `SyncCoordinator` struct is designed to manage the synchronization process,
/// including handling retries and grouping related sync operations.
///
@MainActor struct SyncCoordinator {

    /// An instance conforming to `Database` used for database operations.
    let database: Database

    /// The maximum number of retry attempts for failed sync operations.
    let maxRetry: Int

    /// A `SyncGroup` instance that groups a batch of events.
    let group: SyncGroup
}

extension SyncCoordinator {

    /// Uploads a given `SyncGroup` and `CKRecord` to the server.
    ///
    /// This method uses recursion to handle specific types of errors, such as `CKError.serverRecordChanged`.
    /// If the error occurs, it will retry the upload with the server's version of the record or a new matrix
    /// if the maximum number of retries is exceeded.
    ///
    /// - Parameters:
    ///   - group: The `SyncGroup` to be uploaded.
    ///   - matrix: The `CKRecord` associated with the `SyncGroup`.
    ///
    /// - Throws: An error if the upload fails after the specified number of retries.
    ///
    func upload() async throws {
        let matrix = try await group.matrix(in: database)

        try await upload(matrix: matrix)
    }
}

extension CKRecord {

    /// Merges the given fields into the `CKRecord`.
    ///
    /// This method iterates over the provided fields and updates the corresponding
    /// fields in the `CKRecord` by adding the new values to the existing ones.
    ///
    /// - Parameter fields: A dictionary containing the fields to be merged and their values.
    ///
    func merge(with fields: [String: Int]) {
        for (field, count) in fields {
            let oldCount: Int = self[field] ?? 0
            self[field] = oldCount + count
        }
    }
}

// MARK: - Private Methods

extension SyncCoordinator {

    /// Uploads the given `CKRecord` to the server.
    ///
    /// This method is a convenience wrapper that initiates the upload process
    /// with a retry count of 1.
    ///
    /// - Parameter matrix: The `CKRecord` to be uploaded.
    ///
    /// - Throws: An error if the upload fails after the specified number of retries.
    ///
    fileprivate func upload(matrix: CKRecord) async throws {
        try await upload(matrix: matrix, retry: 1)
    }

    /// Uploads the given `CKRecord` to the server with a specified retry count.
    ///
    /// This method attempts to save the `CKRecord` to the database and handles
    /// specific errors such as `CKError.serverRecordChanged` by retrying the upload
    /// with the server's version of the record or a new matrix if the maximum number
    /// of retries is exceeded.
    ///
    /// - Parameters:
    ///   - matrix: The `CKRecord` to be uploaded.
    ///   - retry: The current retry attempt count.
    ///
    /// - Throws: An error if the upload fails after the specified number of retries.
    ///
    fileprivate func upload(matrix: CKRecord, retry: Int) async throws {
        matrix.merge(with: group.fields)

        do {
            try await database.save(matrix)

            try await database.modifyRecords(
                saving: group.events.map(toRecord),
                deleting: []
            )

        } catch let error as CKError where error.code == CKError.serverRecordChanged {
            if retry > maxRetry {
                try await upload(matrix: group.newMatrix())
            } else if let serverMatrix = error.userInfo[CKRecordChangedErrorServerRecordKey]
                as? CKRecord
            {
                try await upload(matrix: serverMatrix, retry: retry + 1)
            } else {
                throw error
            }
        }
    }
}
