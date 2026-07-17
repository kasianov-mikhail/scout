//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct Record: Sendable {
    public let recordType: String
    public let recordID: String

    public var fields: [String: RecordValue] = [:]
    public var metadata: Data?

    public init(recordType: String, recordID: String, fields: [String: RecordValue] = [:], metadata: Data? = nil) {
        self.recordType = recordType
        self.recordID = recordID
        self.fields = fields
        self.metadata = metadata
    }

    public subscript<T: RecordValueConvertible>(key: String) -> T? {
        get { fields[key].flatMap(T.init(recordValue:)) }
        set { fields[key] = newValue?.recordValue }
    }

    public mutating func setValues(_ values: [String: Any]) {
        fields.merge(values.compactMapValues(RecordValue.init(any:))) { _, new in new }
    }
}

public protocol RecordEncodable {
    static var recordType: String { get }
    var record: Record { get }
}
