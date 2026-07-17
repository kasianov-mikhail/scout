//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

public struct RecordChunk {
    public let records: [Record]
    public let cursor: RecordCursor?

    public init(records: [Record], cursor: RecordCursor?) {
        self.records = records
        self.cursor = cursor
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        RecordChunk(records: lhs.records + rhs.records, cursor: rhs.cursor)
    }
}

public struct RecordCursor: Sendable {
    public let next: @Sendable ([String]?) async throws -> RecordChunk

    public init(next: @escaping @Sendable ([String]?) async throws -> RecordChunk) {
        self.next = next
    }
}
