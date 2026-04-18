//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A type that identifies itself by a CloudKit record type name.
protocol RecordTyped {
    static var recordType: String { get }
}

/// Can be constructed from a `CKRecord` fetched from CloudKit.
protocol CKInitializable {
    init(record: CKRecord) throws
}

/// Can be serialized into a `CKRecord` to write back to CloudKit.
protocol CKRepresentable {
    var toRecord: CKRecord { get }
}
