//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Wire representation of a single record, the JSON shape exchanged with a
/// Scout server. It converts to and from the neutral ``Record`` the rest of
/// the package uses.
///
struct HTTPRecord: Codable, Equatable, Sendable {
    let recordType: String
    let recordName: String
    var fields: [String: RecordValue]
}

extension HTTPRecord {
    init(record: Record) {
        recordType = record.recordType
        recordName = record.recordName
        fields = record.fields
    }

    var toRecord: Record {
        Record(
            recordType: recordType,
            id: RecordID(recordName: recordName),
            fields: fields
        )
    }
}
