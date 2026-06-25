//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HTTPRecord: Codable, Equatable, Sendable {
    let recordType: String
    let recordID: String
    let fields: [String: RecordValue]
}

extension HTTPRecord {
    init(record: Record) {
        recordType = record.recordType
        recordID = record.recordID
        fields = record.fields
    }

    func toRecord() -> Record {
        Record(recordType: recordType, recordID: recordID, fields: fields)
    }
}
