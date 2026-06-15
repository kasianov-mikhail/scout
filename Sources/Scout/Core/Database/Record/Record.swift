//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A backend-neutral record — the currency the package reads, writes, and
/// decodes instead of a `CKRecord`.
///
/// Fields are accessed through the same typed subscript a `CKRecord` offers
/// (`record["name"]`), so decoders read unchanged. ``metadata`` carries an
/// opaque, backend-owned blob — CloudKit's encoded system fields, used to
/// preserve a record's change tag across a conflict retry — and stays `nil`
/// for backends that don't need it.
///
struct Record: Equatable, Sendable {
    let recordType: String
    var id: RecordID
    var fields: [String: RecordValue]
    var metadata: Data?

    init(recordType: String, id: RecordID, fields: [String: RecordValue] = [:], metadata: Data? = nil) {
        self.recordType = recordType
        self.id = id
        self.fields = fields
        self.metadata = metadata
    }

    /// The record's name, a shorthand for `id.recordName`.
    var recordName: String { id.recordName }

    subscript<T: RecordValueConvertible>(key: String) -> T? {
        get { fields[key].flatMap(T.init(recordValue:)) }
        set { fields[key] = newValue?.recordValue }
    }

    /// The keys of the fields the record currently holds.
    func allKeys() -> [String] {
        Array(fields.keys)
    }

    /// Merges a loosely-typed dictionary — an object's `metadata` of shared
    /// fields — into the record, skipping values with no ``RecordValue`` form.
    ///
    mutating func setValues(_ values: [String: Any]) {
        for (key, value) in values {
            if let value = RecordValue(any: value) {
                fields[key] = value
            }
        }
    }
}
