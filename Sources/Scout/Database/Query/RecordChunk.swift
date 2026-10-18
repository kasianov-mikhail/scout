//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package let defaultRecordPageSize = 400

package struct RecordChunk {
    package let records: [Record]
    package let cursor: RecordCursor?

    package init(records: [Record], cursor: RecordCursor?) {
        self.records = records
        self.cursor = cursor
    }
}

package struct RecordCursor: Sendable {
    package let next: @Sendable ([String]?) async throws -> RecordChunk

    package init(next: @escaping @Sendable ([String]?) async throws -> RecordChunk) {
        self.next = next
    }
}
