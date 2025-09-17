//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias DatabaseResult = (
    saveResults: [CKRecord.ID: Result<CKRecord, any Error>],
    deleteResults: [CKRecord.ID: Result<Void, any Error>]
)

protocol Database: Sendable {
    @discardableResult
    func save(_ record: CKRecord) async throws -> CKRecord

    @discardableResult
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID]) async throws -> DatabaseResult

    func allRecords(matching query: CKQuery, desiredKeys: [CKRecord.FieldKey]?) async throws -> [CKRecord]
}

