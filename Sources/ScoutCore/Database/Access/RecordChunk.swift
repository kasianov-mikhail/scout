//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct RecordChunk {
    package let records: [Record]
    package let cursor: RecordCursor?

    package init(records: [Record], cursor: RecordCursor?) {
        self.records = records
        self.cursor = cursor
    }

    package static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    package static func + (lhs: Self, rhs: Self) -> Self {
        RecordChunk(records: lhs.records + rhs.records, cursor: rhs.cursor)
    }
}

package struct RecordCursor: Sendable {
    package let next: @Sendable ([String]?) async throws -> RecordChunk

    package init(next: @escaping @Sendable ([String]?) async throws -> RecordChunk) {
        self.next = next
    }
}
