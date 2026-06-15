//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct RecordChunk {
    let records: [Record]
    let cursor: RecordCursor?
}

// MARK: - Operators

extension RecordChunk {
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        RecordChunk(
            records: lhs.records + rhs.records,
            cursor: rhs.cursor
        )
    }
}
