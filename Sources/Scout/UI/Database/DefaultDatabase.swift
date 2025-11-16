//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct DefaultDatabase: AppDatabase {
    func write(record: CKRecord) async throws {

    }

    func write(records: [CKRecord]) async throws {

    }

    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: Event.sampleRecords, cursor: nil)
    }

    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(id: CKRecord.ID) async throws -> CKRecord {
        Event.sampleRecords.randomElement()!
    }
}
