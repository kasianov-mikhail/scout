//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct Record: Sendable {
    package let recordType: String
    package let recordID: String

    package var fields: [String: RecordValue] = [:]
    package var metadata: Data?

    package init(recordType: String, recordID: String, fields: [String: RecordValue] = [:], metadata: Data? = nil) {
        self.recordType = recordType
        self.recordID = recordID
        self.fields = fields
        self.metadata = metadata
    }

    package subscript<T: RecordValueConvertible>(key: String) -> T? {
        get { fields[key].flatMap(T.init(recordValue:)) }
        set { fields[key] = newValue?.recordValue }
    }

    package mutating func setValues(_ values: [String: Any]) {
        fields.merge(values.compactMapValues(RecordValue.init(any:))) { _, new in new }
    }
}

package protocol RecordEncodable {
    static var recordType: String { get }
    var record: Record { get }
}
