//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

struct CachedRecordPayload: Codable {
    let recordType: String
    let recordID: String
    let fields: [String: RecordValue]
    let metadata: Data?

    init(record: Record) {
        self.recordType = record.recordType
        self.recordID = record.recordID
        self.fields = record.fields
        self.metadata = record.metadata
    }

    var record: Record {
        Record(recordType: recordType, recordID: recordID, fields: fields, metadata: metadata)
    }
}
