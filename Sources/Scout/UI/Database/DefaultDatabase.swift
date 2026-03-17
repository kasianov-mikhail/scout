//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct DefaultDatabase: AppDatabase {
    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        let records: [CKRecord]

        switch query.recordType {
        case "Crash":
            records = Crash.sampleRecords
        case "DateIntMatrix":
            records = Self.sampleMatrixRecords
        default:
            records = Event.sampleRecords
        }

        return RecordChunk(records: records, cursor: nil)
    }

    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(id: CKRecord.ID) async throws -> CKRecord {
        Event.sampleRecords.randomElement()!
    }

    // MARK: - Sample Matrix Records

    private static var sampleMatrixRecords: [CKRecord] {
        let calendar = Calendar.utc
        let today = Date().startOfDay

        return (-52...0).compactMap { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) else {
                return nil
            }

            let record = CKRecord(recordType: "DateIntMatrix")
            record["date"] = weekStart
            record["name"] = "event_name"

            for day in 1...7 {
                let count = Int.random(in: 1...10)
                let hour = Int.random(in: 8...18)
                record["cell_\(day)_\(String(format: "%02d", hour))"] = count
            }

            return record
        }
    }
}
