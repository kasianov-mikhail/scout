//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A type that identifies itself by a record type name.
protocol RecordTyped {
    static var recordType: String { get }
}

/// Can be constructed from a ``Record`` read back from a backend.
protocol RecordDecodable {
    init(record: Record) throws
}

/// Can be serialized into a ``Record`` to write back to a backend.
protocol RecordRepresentable {
    var toRecord: Record { get }
}
