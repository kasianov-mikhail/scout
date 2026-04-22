//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A type that can be initialized from a CloudKit record.
///
/// Conforming types provide an `init(record:)` initializer that decodes
/// a `CKRecord` into a UI model. A default `init(results:)` convenience
/// initializer is provided that unwraps the result tuple returned by
/// CloudKit batch fetch operations.
///
protocol RecordDecodable {
    init(record: CKRecord) throws
}

extension RecordDecodable {
    init(results: (CKRecord.ID, Result<CKRecord, Error>)) throws {
        try self.init(record: results.1.get())
    }
}
