//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DefaultDatabase: AppDatabase {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        let records: [Record]

        switch query.recordType {
        case CrashObject.recordType:
            records = Crash.sampleRecords
        case Int.recordType:
            records = GridMatrix<Int>.sampleRecords
        case PeriodCell<Int>.recordType:
            records = ActivityMatrix.sampleRecords
        default:
            records = Event.sampleRecords
        }

        return RecordChunk(records: records, cursor: nil)
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(id: RecordID, fields: [String]?) async throws -> Record {
        Event.sampleRecords.randomElement()!
    }
}
