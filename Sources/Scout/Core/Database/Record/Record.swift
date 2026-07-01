//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct Record: Sendable {
    let recordType: String
    let recordID: String

    var fields: [String: RecordValue] = [:]
    var metadata: Data?

    subscript<T: RecordValueConvertible>(key: String) -> T? {
        get { fields[key].flatMap(T.init(recordValue:)) }
        set { fields[key] = newValue?.recordValue }
    }

    mutating func setValues(_ values: [String: Any]) {
        fields.merge(values.compactMapValues(RecordValue.init(any:))) { _, new in new }
    }
}

protocol RecordEncodable {
    static var recordType: String { get }
    var record: Record { get }
}
