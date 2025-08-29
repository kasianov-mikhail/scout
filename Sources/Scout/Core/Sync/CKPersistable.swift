//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

typealias CKPersistable = CKInitializable & CKRepresentable

protocol CKInitializable {
    init(record: CKRecord) throws
}

protocol CKRepresentable {
    var toRecord: CKRecord { get }
}
