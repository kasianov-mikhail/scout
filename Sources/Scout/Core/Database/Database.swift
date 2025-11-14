//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

protocol Database: Sendable {
    func store(record: CKRecord) async throws

    func store(records: [CKRecord]) async throws

    func fetchAll(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> [CKRecord]
}
