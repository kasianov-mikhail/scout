//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RecordChunk {
    package static func page(of matches: [Record], limit: Int, after offset: Int = 0) -> RecordChunk {
        let page = matches.dropFirst(offset).prefix(limit)
        let next = offset + page.count

        return RecordChunk(
            records: Array(page),
            cursor: next < matches.count
                ? RecordCursor { _ in Self.page(of: matches, limit: limit, after: next) }
                : nil
        )
    }
}
